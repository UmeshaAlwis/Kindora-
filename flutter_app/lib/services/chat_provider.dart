import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../logic/ai_agent.dart';

/// Chat state provider
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
  final AIAgent _aiAgent = AIAgent();

  bool _isLoading = false;
  String? _error;

  ChatNotifier(this._chatService) : super([]);

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Send message and get response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _error = null;
    _isLoading = true;

    try {
      // ✅ Add user message immediately
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      state = [...state, userMsg];

      // ✅ Detect intent using AI
      final intent = _aiAgent.detectIntent(message);

      String reply;
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();

      // ✅ Decision logic (AI + Backend)
      if (intent == "donate") {
        final response = await _chatService.sendMessage(message);

        if (response.success) {
          reply = response.reply;
          messageId = response.messageId;
        } else {
          reply = response.error ?? 'Failed to process donation request';
          _error = reply;
        }
      } 
      else if (intent == "search") {
        reply = "Let me find relevant charities for you...";
      } 
      else if (intent == "scam") {
        reply = "Your report has been submitted. Our team will review it.";
      } 
      else {
        // Default AI response
        reply = _aiAgent.processMessage(message);
      }

      // ✅ Add bot response
      final botMsg = ChatMessage(
        id: messageId,
        content: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, botMsg];

    } catch (e) {
      _error = e.toString();

      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'An error occurred: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, errorMsg];
    } finally {
      _isLoading = false;
    }
  }

  /// Clear chat history
  void clearHistory() {
    state = [];
    _chatService.clearHistory();
    _error = null;
  }

  /// Load previous conversation
  void loadConversation(List<ChatMessage> messages) {
    state = messages;
  }
}

/// Provider for chat service
final chatServiceProvider = Provider((ref) => ChatService());

/// Provider for chat state (messages)
final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatNotifier(chatService);
});

/// Provider for loading state
final chatLoadingProvider = Provider<bool>((ref) {
  final notifier = ref.watch(chatProvider.notifier);
  return notifier.isLoading;
});