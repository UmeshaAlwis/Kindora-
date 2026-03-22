import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/config/themes/app_colors.dart';
import 'package:kindora/core/navigation/kindora_app_role.dart';
import 'package:kindora/core/navigation/navigation_agent.dart';
import 'package:kindora/providers/app_role_provider.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

/// Chat window widget - displays as a modal or overlay
class ChatWindow extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const ChatWindow({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends ConsumerState<ChatWindow> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    _messageController.clear();

    // Role-aware navigation agent (whitelist only — never routes across roles).
    final role = ref.read(currentAppRoleProvider).maybeWhen(
          data: (r) => r,
          orElse: () => KindoraAppRole.donor,
        );
    final nav = NavigationAgent.resolve(userText, role);

    switch (nav) {
      case NavigationNavigate(:final path, :final assistantMessage):
        ref
            .read(chatProvider.notifier)
            .appendUserAndAssistant(userText, assistantMessage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go(path);
          widget.onClose?.call();
        });
        _scrollToBottom();
        return;
      case NavigationClarify(:final message):
        ref
            .read(chatProvider.notifier)
            .appendUserAndAssistant(userText, message);
        _scrollToBottom();
        return;
      case NavigationForwardToChat():
        break;
    }

    await ref.read(chatProvider.notifier).sendMessage(userText);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatProvider.notifier).isLoading;
    final role = ref.watch(currentAppRoleProvider).maybeWhen(
          data: (r) => r,
          orElse: () => KindoraAppRole.donor,
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kindora assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${role.displayLabel} • Navigate or ask',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    widget.onClose?.call();
                  },
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'How can we help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try “Open wallet” or “Go to feed” — destinations match your '
                            '${role.displayLabel} account.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: NavigationAgent.quickPhrases(role)
                                .map(
                                  (q) => ActionChip(
                                    label: Text(q.label),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            _messageController.text =
                                                q.examplePhrase;
                                            _sendMessage();
                                          },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          // Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.accentGradient,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  child: FloatingActionButton(
                    onPressed: isLoading ? null : _sendMessage,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(
                      isLoading ? Icons.hourglass_bottom : Icons.send,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryBlue
                    : AppColors.scaffoldLight,
                borderRadius: BorderRadius.circular(12),
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
