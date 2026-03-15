import { Router, Request, Response } from 'express';
import Logger from '../utils/logger';
import axios from 'axios';

const router = Router();
const logger = new Logger('CHAT');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

// Fallback keyword responses
const fallbackResponses: { [key: string]: string } = {
  hello: 'Hello! Welcome to Kindora. How can I assist you today?',
  hi: 'Hi there! I\'m here to help. What would you like to know about Kindora?',
  help: 'I can help you with:\n• Information about campaigns\n• How to donate\n• Creating a campaign\n• Payment methods\n• Account management',
  campaign: 'Campaigns are fundraising initiatives created by charities to collect donations for specific causes.',
  donate: 'To donate:\n1. Browse campaigns\n2. Select amount\n3. Choose payment method\n4. Complete payment',
  payment: 'We accept payments through PayHere with multiple payment methods.',
  create: 'To create a campaign: verify charity → provide details → set goal → add description & images → launch.',
  account: 'Manage your account in Settings to update info and view activity.',
  security: 'Kindora uses encryption and secure payment gateways to protect your information.',
  why: 'Donating helps support important causes and makes a real difference in people\'s lives.',
};

/**
 * POST /api/chat
 * Send a message to the chatbot and get a response using Gemini API
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const { sessionId, message, conversationHistory } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Message is required and must be a string',
      });
    }

    logger.info(`Chat message from session ${sessionId}: ${message.substring(0, 50)}...`);

    // Get response from Gemini API
    const response = await getGeminiResponse(message, conversationHistory);

    res.json({
      success: true,
      reply: response,
      messageId: `msg_${Date.now()}`,
      timestamp: new Date().toISOString(),
      sessionId,
    });
  } catch (error: any) {
    logger.error('Chat error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process chat message',
    });
  }
});

/**
 * Get response from Google Gemini API with fallback to keyword matching
 */
async function getGeminiResponse(userMessage: string, conversationHistory: any[] = []): Promise<string> {
  // Try Gemini API if key is available
  if (GEMINI_API_KEY) {
    try {
      const response = await axios.post(
        `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
        {
          contents: [
            {
              parts: [
                {
                  text: `You are Kindora Assistant for a charity platform. Answer briefly (1-2 sentences) about campaigns, donations, payments, and accounts. User: ${userMessage}`,
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 150,
          },
        },
        {
          timeout: 5000,
        }
      );

      const reply = response.data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
      
      if (reply) {
        logger.info(`Gemini response: ${reply.substring(0, 50)}...`);
        return reply;
      }
    } catch (error: any) {
      const errorMsg = error.response?.data?.error?.message || error.message || 'Unknown error';
      const statusCode = error.response?.status || 'N/A';
      logger.warn(`Gemini API error (Status: ${statusCode}): ${errorMsg}. Falling back to keyword matching.`);
      logger.debug(`Full error response:`, error.response?.data);
      // Fall through to keyword matching
    }
  }

  // Fallback to keyword matching
  const lowerMessage = userMessage.toLowerCase().trim();
  
  for (const [keyword, response] of Object.entries(fallbackResponses)) {
    if (lowerMessage.includes(keyword)) {
      logger.info(`Matched keyword: ${keyword}`);
      return response;
    }
  }

  return 'I\'m not sure about that. You can ask me about campaigns, donations, payments, creating campaigns, or managing your account.';
}

/**
 * GET /api/chat/session/:sessionId
 * Get chat session history
 */
router.get('/session/:sessionId', async (req: Request, res: Response) => {
  try {
    const { sessionId } = req.params;

    // In a real app, you would fetch this from database
    logger.info(`Retrieving chat history for session ${sessionId}`);

    res.json({
      success: true,
      sessionId,
      messages: [],
      createdAt: new Date().toISOString(),
    });
  } catch (error: any) {
    logger.error('Session retrieval error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to retrieve session',
    });
  }
});

/**
 * DELETE /api/chat/session/:sessionId
 * Clear chat session
 */
router.delete('/session/:sessionId', async (req: Request, res: Response) => {
  try {
    const { sessionId } = req.params;

    logger.info(`Clearing chat session ${sessionId}`);

    res.json({
      success: true,
      message: 'Chat session cleared',
      sessionId,
    });
  } catch (error: any) {
    logger.error('Session clearance error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to clear session',
    });
  }
});

export default router;
