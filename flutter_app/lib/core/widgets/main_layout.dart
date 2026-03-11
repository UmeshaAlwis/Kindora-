import 'package:flutter/material.dart';
import '../../features/chat/ui/chat_assistant_button.dart';

/// Main layout wrapper with persistent chat assistant
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: child,
          ),

          // Chat assistant floating button
          const ChatAssistantButton(showBadge: true),
        ],
      ),
    );
  }
}