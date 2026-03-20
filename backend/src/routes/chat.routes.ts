import { Router, Request, Response } from 'express';
import Logger from '../utils/logger';
import axios from 'axios';

const router = Router();
const logger = new Logger('CHAT');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_API_BASE = 'https://generativelanguage.googleapis.com/v1beta/models';
const GEMINI_MODELS = ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro'];
let cachedAvailableModels: string[] | null = null;
let cachedAtMs = 0;
const MODEL_CACHE_TTL_MS = 10 * 60 * 1000;

async function getAvailableGeminiModels(): Promise<string[]> {
  if (!GEMINI_API_KEY) {
    return [];
  }

  const now = Date.now();
  if (cachedAvailableModels && now - cachedAtMs < MODEL_CACHE_TTL_MS) {
    return cachedAvailableModels;
  }

  try {
    const response = await axios.get(`${GEMINI_API_BASE}?key=${GEMINI_API_KEY}`, {
      timeout: 8000,
    });

    const models: string[] = (response.data?.models ?? [])
      .filter((m: any) => Array.isArray(m?.supportedGenerationMethods) && m.supportedGenerationMethods.includes('generateContent'))
      .map((m: any) => String(m?.name ?? '').replace(/^models\//, ''))
      .filter((name: string) => !!name);

    const preferred = GEMINI_MODELS.filter((m) => models.includes(m));
    const ordered = [...preferred, ...models.filter((m) => !preferred.includes(m))];

    cachedAvailableModels = ordered;
    cachedAtMs = now;
    return ordered;
  } catch (error: any) {
    const errorMsg = error.response?.data?.error?.message || error.message || 'Unknown error';
    const statusCode = error.response?.status || 'N/A';
    logger.warn(`Gemini ListModels failed (Status: ${statusCode}): ${errorMsg}`);
    return GEMINI_MODELS;
  }
}

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
  database:
    'Kindora database includes core tables like users, campaigns, beneficiary_campaigns, donations, wallets, wallet_transactions, messages, notifications, merchandise, campaign_volunteers, feed_posts, feed_post_likes, and merchandise_orders.',
  tables:
    'Main Kindora tables: users, campaigns, beneficiary_campaigns, donations, wallets, wallet_transactions, messages, notifications, merchandise, campaign_volunteers, feed_posts, feed_post_likes, merchandise_orders.',
  volunteer:
    'Volunteers can browse campaigns that need volunteers, join them, chat with donors, and manage joined campaigns from their volunteer dashboard.',
  beneficiary:
    'Beneficiaries can complete profile details, create beneficiary campaigns, track progress, and receive donations to their wallet.',
  merch:
    'Merchandise is managed from admin dashboard and shown in mobile Merch page. Donors can purchase items with wallet or card.',
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
  const appKnowledge = `
Kindora app/domain knowledge:
- Roles: donor, beneficiary, volunteer (charity), admin.
- Donor: campaign donations, beneficiary donations, wallet top-up, notifications, merch purchase.
- Beneficiary: profile completion, beneficiary campaigns, wallet earnings.
- Volunteer: view campaigns needing volunteers, join/leave, chat with donor.
- Admin dashboard: manage users, campaigns, beneficiary campaigns, merchandise, feed moderation.
- Common database tables: users, campaigns, beneficiary_campaigns, donations, wallets, wallet_transactions, messages, notifications, merchandise, campaign_volunteers, feed_posts, feed_post_likes, merchandise_orders.
- Storage: campaign/merch images are uploaded to Supabase Storage and stored as URLs.
`;

  const historyText = (conversationHistory || [])
    .slice(-8)
    .map((m: any) => `${m?.isUser ? 'User' : 'Assistant'}: ${m?.content ?? ''}`)
    .join('\n');

  // Try Gemini API if key is available
  if (GEMINI_API_KEY) {
    const modelsToTry = await getAvailableGeminiModels();
    for (const model of modelsToTry) {
      try {
        const response = await axios.post(
          `${GEMINI_API_BASE}/${model}:generateContent?key=${GEMINI_API_KEY}`,
          {
            contents: [
              {
                parts: [
                  {
                    text: `You are Kindora Assistant for a charity platform.
Use only known Kindora context below. If unsure, say what information is missing.
Keep answers practical, clear, and concise.

${appKnowledge}

Conversation:
${historyText || '(none)'}

User question: ${userMessage}`,
                  },
                ],
              },
            ],
            generationConfig: {
              temperature: 0.4,
              maxOutputTokens: 300,
            },
          },
          {
            timeout: 8000,
          }
        );

        const reply =
          response.data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

        if (reply) {
          logger.info(`Gemini response using ${model}: ${reply.substring(0, 50)}...`);
          return reply;
        }
      } catch (error: any) {
        const errorMsg =
          error.response?.data?.error?.message || error.message || 'Unknown error';
        const statusCode = error.response?.status || 'N/A';
        logger.warn(`Gemini API error with ${model} (Status: ${statusCode}): ${errorMsg}`);
        logger.debug(`Full error response:`, error.response?.data);
      }
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

  return 'I can help with Kindora app features and database topics (roles, campaigns, donations, wallet, feed, merch, admin). Please ask a specific question.';
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

/**
 * GET /api/chat/health
 * Quick health/status for chatbot integration mode.
 */
router.get('/health', async (_req: Request, res: Response) => {
  const available_models = GEMINI_API_KEY ? await getAvailableGeminiModels() : [];
  res.json({
    success: true,
    provider: GEMINI_API_KEY ? 'gemini' : 'fallback',
    gemini_configured: !!GEMINI_API_KEY,
    model_candidates: GEMINI_MODELS,
    available_models,
    timestamp: new Date().toISOString(),
  });
});

export default router;
