import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';



/// Chat state provider
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatService _chatService;
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
      // Add user message immediately
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      state = [...state, userMsg];

      // Send to backend
      final response = await _chatService.sendMessage(message);
      print(
          '[ChatProvider] Response success: ${response.success}, Reply: ${response.reply}');

      if (response.success) {
        // Add bot response
        final botMsg = ChatMessage(
          id: response.messageId,
          content: response.reply,
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = [...state, botMsg];
      } else {
        _error = response.error ?? 'Failed to get response';
        print('[ChatProvider] Error: $_error');
        // Add error message
        final errorMsg = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Sorry, I encountered an error: ${response.error}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = [...state, errorMsg];
      }
    } catch (e) {
      _error = e.toString();
      print('[ChatProvider] Exception: $_error');
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
