import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../models/chat_model.dart';

/// Service to handle chatbot API communication
class ChatService {
  static final ChatService _instance = ChatService._internal();

  // ✅ Smart base URL (Web vs Mobile)
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api'; // Web
    } else {
      return 'http://10.0.2.2:5001/api'; // Android emulator
    }
  }

  static const String _chatEndpoint = '/chat';

  late String _sessionId;
  List<ChatMessage> _conversationHistory = [];

  factory ChatService() {
    return _instance;
  }

  ChatService._internal() {
    _sessionId = const Uuid().v4();
  }

  /// 🔥 Toggle here (ONLY CHANGE THIS)
  static const bool useFakeAI = true;

  /// Send message to chatbot and get response
  Future<ChatResponse> sendMessage(String userMessage) async {
    try {
      // ✅ Add user message
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _conversationHistory.add(userMsg);

      // ==================================================
      // 🤖 FAKE AI MODE (SAFE - NO BACKEND REQUIRED)
      // ==================================================
      if (useFakeAI) {
        await Future.delayed(const Duration(milliseconds: 500));

        final chatResponse = ChatResponse(
          reply: "AI says: $userMessage",
          messageId: const Uuid().v4(),
          success: true,
        );

        final botMsg = ChatMessage(
          id: chatResponse.messageId,
          content: chatResponse.reply,
          isUser: false,
          timestamp: DateTime.now(),
        );

        _conversationHistory.add(botMsg);

        return chatResponse;
      }

      // ==================================================
      // 🌐 REAL API MODE (UNCHANGED)
      // ==================================================
      final requestBody = {
        'sessionId': _sessionId,
        'message': userMessage,
        'conversationHistory':
            _conversationHistory.map((m) => m.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl$_chatEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      // ✅ SUCCESS
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final chatResponse = ChatResponse.fromJson(jsonResponse);

        if (chatResponse.success) {
          final botMsg = ChatMessage(
            id: chatResponse.messageId.isNotEmpty
                ? chatResponse.messageId
                : const Uuid().v4(),
            content: chatResponse.reply,
            isUser: false,
            timestamp: DateTime.now(),
          );

          _conversationHistory.add(botMsg);
        }

        return chatResponse;
      }

      // ❌ SERVER ERROR
      return _errorResponse('Server error (${response.statusCode})');
    }

    // ⏱ NETWORK ERROR
    on http.ClientException catch (_) {
      return _errorResponse('Network error. Check backend.');
    } catch (e) {
      return _errorResponse(e.toString());
    }
  }

  /// ✅ Centralized error handler
  ChatResponse _errorResponse(String message) {
    final fallbackReply = "⚠️ $message\n\nTry again later.";

    return ChatResponse(
      reply: fallbackReply,
      messageId: const Uuid().v4(),
      success: false,
      error: message,
    );
  }

  /// Get conversation history
  List<ChatMessage> getConversationHistory() {
    return _conversationHistory;
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
    _sessionId = const Uuid().v4();
  }

  /// Get current session ID
  String getSessionId() {
    return _sessionId;
  }

  /// Restore conversation
  void restoreConversation(List<ChatMessage> messages, String sessionId) {
    _conversationHistory = messages;
    _sessionId = sessionId;
  }
}

final chatService = ChatService();