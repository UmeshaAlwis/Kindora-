# Chatbot Assistance Integration

This document explains how the chatbot assistance feature is integrated into the Kindora mobile app and backend.

## Features

- 💬 **Floating Chat Button** - Appears in the bottom-right corner of every page
- 🎯 **Instant Response** - Get real-time answers to your questions
- 📱 **Mobile Optimized** - Responsive chat window that works on all screen sizes
- 🔄 **Session Management** - Maintains conversation history within a session
- 🎨 **Beautiful UI** - Modern design with smooth animations

## Mobile App Integration

### Components

1. **ChatMessage Model** (`lib/features/chat/models/chat_model.dart`)
   - Represents a single message in the conversation
   - Contains message content, sender info, and timestamp

2. **ChatSession Model** (`lib/features/chat/models/chat_model.dart`)
   - Represents a chat session with multiple messages
   - Tracks session ID and activity status

3. **ChatService** (`lib/features/chat/services/chat_service.dart`)
   - Handles API communication with the backend
   - Manages conversation history
   - Singleton pattern for app-wide access

4. **ChatProvider** (`lib/features/chat/providers/chat_provider.dart`)
   - Riverpod state management for chat messages
   - Handles loading states and error management

5. **ChatWindow** (`lib/features/chat/ui/chat_window.dart`)
   - Main chat UI component
   - Displays message bubbles and input field
   - Real-time message display

6. **ChatAssistantButton** (`lib/features/chat/ui/chat_assistant_button.dart`)
   - Floating action button (bottom-right corner)
   - Opens/closes the chat modal
   - Shows badge indicator

### Implementation

The chat button is integrated into every page through `MainLayout`:

```dart
// In main_layout.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        SafeArea(child: child),
        const ChatAssistantButton(showBadge: true),  // ← Floating chat button
      ],
    ),
    // ... bottom navigation bar
  );
}
```

### Usage

The feature is now automatically available on all main app pages (Dashboard, Campaigns, Profile, Settings).

Users can:
1. Click the floating button (bottom-right) with the support agent icon
2. Type a message in the chat window
3. Get instant responses
4. Clear chat history and start a new session

## Backend API

### Endpoints

#### POST `/api/chat`
Send a message to the chatbot and get a response.

**Request:**
```json
{
  "sessionId": "uuid-string",
  "message": "What is a campaign?",
  "conversationHistory": [
    { "id": "msg_1", "content": "Hello", "isUser": true, "timestamp": "..." }
  ],
  "timestamp": "2026-03-08T..."
}
```

**Response:**
```json
{
  "success": true,
  "reply": "Campaigns are fundraising initiatives...",
  "messageId": "msg_123456",
  "timestamp": "2026-03-08T...",
  "sessionId": "uuid-string"
}
```

#### GET `/api/chat/session/:sessionId`
Retrieve chat session history.

**Response:**
```json
{
  "success": true,
  "sessionId": "uuid-string",
  "messages": [...],
  "createdAt": "2026-03-08T..."
}
```

#### DELETE `/api/chat/session/:sessionId`
Clear chat session.

**Response:**
```json
{
  "success": true,
  "message": "Chat session cleared",
  "sessionId": "uuid-string"
}
```

## Configuration

### Backend URL

Update the base URL in `lib/features/chat/services/chat_service.dart`:

```dart
static const String _baseUrl = 'https://your-backend.com/api';
```

Replace `https://kindora.lk/api` with your actual backend URL.

### Chatbot Responses

The chatbot uses keyword matching to provide relevant responses. Update the responses in `backend/src/routes/chat.routes.ts`:

```typescript
const chatbotResponses: { [key: string]: string } = {
  hello: 'Your response here...',
  campaign: 'Another response...',
  // ... more keywords
};
```

## Future Enhancements

- [ ] Integrate with AI/ML for natural language processing (Dialogflow, OpenAI, etc.)
- [ ] Store chat history in database
- [ ] Add file/image sharing in chat
- [ ] User context awareness (logged-in user info)
- [ ] Multi-language support
- [ ] Chat analytics and reporting
- [ ] Admin dashboard to manage chatbot responses
- [ ] Integration with support tickets system

## Testing

### Mobile App

1. Run the Flutter app
2. Navigate to any main page (Dashboard, Campaigns, etc.)
3. Click the floating button in bottom-right corner
4. Type a message and send
5. Verify you receive a response

### Backend API

Test the chat endpoint with curl:

```bash
curl -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-session-123",
    "message": "What is a campaign?",
    "conversationHistory": []
  }'
```

## Troubleshooting

### Chat button not appearing
- Ensure the app is running on a main page (Dashboard, Campaigns, Profile, Settings)
- Check that MainLayout is being used for these pages

### Messages not sending
- Verify backend URL is correct in `chat_service.dart`
- Check backend server is running (`npm run dev`)
- Check network connectivity
- Review backend logs for errors

### No response from chatbot
- Ensure chat route is registered in backend (`index.ts`)
- Check if message keyword matches any response pattern
- Default response should always trigger if no keyword matches

## Architecture

```
Flutter App (Mobile)
    ↓
ChatAssistantButton (UI)
    ↓
ChatWindow (UI)
    ↓
ChatService (API Communication)
    ↓
HTTP POST /api/chat
    ↓
Backend Express Server
    ↓
ChatRoutes.ts (Route Handler)
    ↓
processChatMessage() (Logic)
    ↓
Response back to Mobile App
```

## Files Modified/Created

### Mobile App
- ✅ Created: `lib/features/chat/models/chat_model.dart`
- ✅ Created: `lib/features/chat/services/chat_service.dart`
- ✅ Created: `lib/features/chat/providers/chat_provider.dart`
- ✅ Created: `lib/features/chat/ui/chat_window.dart`
- ✅ Created: `lib/features/chat/ui/chat_assistant_button.dart`
- ✅ Modified: `lib/core/widgets/main_layout.dart` (Added ChatAssistantButton)

### Backend
- ✅ Created: `backend/src/routes/chat.routes.ts`
- ✅ Modified: `backend/src/index.ts` (Added chat route import and registration)

## Next Steps

1. **Update backend URL** in `chat_service.dart` to match your deployed backend
2. **Test the integration** with the mobile app and backend running
3. **Customize chatbot responses** in `chat.routes.ts` based on your needs
4. **Add error handling** for network issues (already partially implemented)
5. **Implement advanced NLP** if needed (Dialogflow, OpenAI API, etc.)

---

For questions or issues, please refer to the main Kindora documentation.
