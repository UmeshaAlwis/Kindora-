import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/config/themes/app_colors.dart';
import 'package:kindora/core/navigation/kindora_app_role.dart';
import 'package:kindora/core/navigation/navigation_agent.dart';
import 'package:kindora/l10n/app_localizations.dart';
import 'package:kindora/providers/app_role_provider.dart';
import 'package:kindora/providers/language_provider.dart';
import 'package:kindora/providers/theme_provider.dart';
import '../assistant_intents.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

String _localizedRoleLabel(KindoraAppRole role, AppLocalizations l10n) {
  return switch (role) {
    KindoraAppRole.donor => l10n.roleDonor,
    KindoraAppRole.beneficiary => l10n.roleBeneficiary,
    KindoraAppRole.volunteer => l10n.roleVolunteer,
  };
}

/// Chat window — theme/language via messages only; navigation agent for routes.
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
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    _messageController.clear();

    final role = ref.read(currentAppRoleProvider).maybeWhen(
          data: (r) => r,
          orElse: () => KindoraAppRole.donor,
        );
    final currentlyDark = ref.read(themeProvider);
    final intent = resolveAssistantIntent(
      userText,
      role,
      currentlyDark: currentlyDark,
    );

    switch (intent) {
      case AssistantThemeIntent(:final useDarkMode):
        await ref.read(themeProvider.notifier).toggleDarkMode(useDarkMode);
        if (!mounted) return;
        final reply = useDarkMode
            ? l10n.chatThemeSetDark
            : l10n.chatThemeSetLight;
        ref
            .read(chatProvider.notifier)
            .appendUserAndAssistant(userText, reply);
        _scrollToBottom();
        return;
      case AssistantLanguageIntent(:final languageCode):
        await ref
            .read(languageProvider.notifier)
            .changeLanguage(languageCode);
        if (!mounted) return;
        final langName = getAvailableLanguages()
            .firstWhere(
              (m) => m['code'] == languageCode,
              orElse: () => {'code': languageCode, 'name': languageCode},
            )['name']!;
        ref.read(chatProvider.notifier).appendUserAndAssistant(
              userText,
              l10n.chatLanguageSet(langName),
            );
        _scrollToBottom();
        return;
      case AssistantNavigationIntent(:final navigation):
        switch (navigation) {
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
            await ref.read(chatProvider.notifier).sendMessage(userText);
            _scrollToBottom();
            return;
        }
      case AssistantChatOnlyIntent():
        await ref.read(chatProvider.notifier).sendMessage(userText);
        _scrollToBottom();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatProvider.notifier).isLoading;
    final role = ref.watch(currentAppRoleProvider).maybeWhen(
          data: (r) => r,
          orElse: () => KindoraAppRole.donor,
        );
    final isDark = ref.watch(themeProvider);
    final roleLabel = _localizedRoleLabel(role, l10n);

    final surface = isDark ? const Color(0xFF1A1B26) : Colors.white;
    final surfaceAlt = isDark ? const Color(0xFF232530) : AppColors.scaffoldLight;
    final onSurface = isDark ? Colors.white.withValues(alpha: 0.92) : Colors.black87;
    final subtle = isDark ? Colors.white.withValues(alpha: 0.55) : Colors.grey;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade200;
    final inputBorder =
        isDark ? Colors.white.withValues(alpha: 0.22) : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.kindoraAssistant,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$roleLabel • ${l10n.assistantNavigateOrAsk}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
          Expanded(
            child: ColoredBox(
              color: surfaceAlt,
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.chatHowCanWeHelp,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: subtle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.chatEmptyNavigationHint(roleLabel),
                              style: TextStyle(
                                fontSize: 13,
                                color: subtle,
                              ),
                              textAlign: TextAlign.center,
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
                        return _buildMessageBubble(
                          message,
                          isDark: isDark,
                          onSurface: onSurface,
                          botBubble: isDark
                              ? const Color(0xFF2E3142)
                              : AppColors.scaffoldLight,
                          botBorder: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.border,
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isLoading,
                    style: TextStyle(color: onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.chatTypeYourMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? surfaceAlt : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.grey.shade400,
                      ),
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
                      color: Colors.white,
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

  Widget _buildMessageBubble(
    ChatMessage message, {
    required bool isDark,
    required Color onSurface,
    required Color botBubble,
    required Color botBorder,
  }) {
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
                color: message.isUser ? AppColors.primaryBlue : botBubble,
                borderRadius: BorderRadius.circular(12),
                border: message.isUser
                    ? null
                    : Border.all(color: botBorder),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : onSurface,
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
              backgroundColor:
                  AppColors.primaryOrange.withValues(alpha: 0.25),
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
