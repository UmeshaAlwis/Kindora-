import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/chat_window.dart';

/// Floating chat button widget - add this to your app root or scaffold
class ChatAssistantButton extends ConsumerStatefulWidget {
  final bool showBadge;

  const ChatAssistantButton({
    super.key,
    this.showBadge = true,
  });

  @override
  ConsumerState<ChatAssistantButton> createState() =>
      _ChatAssistantButtonState();
}

class _ChatAssistantButtonState extends ConsumerState<ChatAssistantButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });

    if (_isChatOpen) {
      _animationController.forward();
      _showChatModal();
    } else {
      _animationController.reverse();
    }
  }

  void _showChatModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 768
                    ? 400
                    : MediaQuery.of(context).size.width - 32,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Material(
                  child: ChatWindow(
                    onClose: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      setState(() {
                        _isChatOpen = false;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isChatOpen = false;
        });
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Quick access buttons (optional)
          if (_isChatOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildQuickButton('📚 FAQ', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('FAQ section coming soon')),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildQuickButton('💬 Chat', () {
                    _toggleChat();
                  }),
                ],
              ),
            ),
          // Main floating button
          GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isChatOpen
                        ? Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                            key: ValueKey(_isChatOpen),
                          )
                        : Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 28,
                            key: ValueKey(_isChatOpen),
                          ),
                  ),
                  // Badge
                  if (widget.showBadge && !_isChatOpen)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget to add chat assistant to any page
class WithChatAssistant extends ConsumerWidget {
  final Widget child;
  final bool showBadge;

  const WithChatAssistant({
    super.key,
    required this.child,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        ChatAssistantButton(showBadge: showBadge),
      ],
    );
  }
}
