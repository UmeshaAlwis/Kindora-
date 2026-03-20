import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:kindora/config/app_env.dart';
import '../models/chat_model.dart';

/// Service to handle chatbot API communication
class ChatService {
  static final ChatService _instance = ChatService._internal();
  // Keep chat base URL aligned with app-wide API environment.
  static String get _baseUrl => AppEnv.apiBaseUrl;
  static const String _chatEndpoint = '/chat';

  late String _sessionId;
  List<ChatMessage> _conversationHistory = [];

  factory ChatService() {
    return _instance;
  }

  ChatService._internal() {
    _sessionId = const Uuid().v4();
  }

  /// Send message to chatbot and get response
  Future<ChatResponse> sendMessage(String userMessage) async {
    try {
      // Add user message to history
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _conversationHistory.add(userMsg);

      // Prepare request body
      final requestBody = {
        'sessionId': _sessionId,
        'message': userMessage,
        'conversationHistory':
            _conversationHistory.map((m) => m.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Make API call
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_chatEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response(
              jsonEncode({'success': false, 'error': 'Request timeout'}),
              408,
            ),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('[ChatService] Response: $jsonResponse');
        final chatResponse = ChatResponse.fromJson(jsonResponse);

        // Add bot response to history
        if (chatResponse.success) {
          final botMsg = ChatMessage(
            id: chatResponse.messageId,
            content: chatResponse.reply,
            isUser: false,
            timestamp: DateTime.now(),
          );
          _conversationHistory.add(botMsg);
        }

        return chatResponse;
      } else {
        print(
            '[ChatService] Error: Status code ${response.statusCode}, Body: ${response.body}');
        return ChatResponse(
          reply: 'Error: Unable to get response',
          messageId: '',
          success: false,
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[ChatService] Exception: $e');
      return ChatResponse(
        reply: 'Error: ${e.toString()}',
        messageId: '',
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get conversation history
  List<ChatMessage> getConversationHistory() {
    return _conversationHistory;
  }

  /// Clear conversation history and start new session
  void clearHistory() {
    _conversationHistory.clear();
    _sessionId = const Uuid().v4();
  }

  /// Get current session ID
  String getSessionId() {
    return _sessionId;
  }

  /// Restore conversation from previous session
  void restoreConversation(List<ChatMessage> messages, String sessionId) {
    _conversationHistory = messages;
    _sessionId = sessionId;
  }
}

final chatService = ChatService();
