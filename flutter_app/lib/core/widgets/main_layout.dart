import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/ui/chat_assistant_button.dart';

/// Main layout wrapper with persistent bottom navigation bar and chat assistant
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  int _getSelectedIndex(String location) {
    // Beneficiary routes map to Home (index 0)
    if (location.startsWith('/beneficiary/dashboard')) return 0;
    if (location.startsWith('/beneficiary/profile')) return 4;
    if (location.startsWith('/beneficiary')) return 0;

    // Donor routes
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/merch')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current route location to determine active nav index
    final location = GoRouterState.of(context).location;

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getSelectedIndex(location),
        onTap: (index) {
          // Check if user is on beneficiary routes
          final isBeneficiary = location.startsWith('/beneficiary');

          print('[MainLayout] Tapped index: $index');
          print('[MainLayout] Current location: $location');
          print('[MainLayout] Is beneficiary: $isBeneficiary');

          switch (index) {
            case 0:
              final route =
                  isBeneficiary ? '/beneficiary/dashboard' : '/dashboard';
              print('[MainLayout] Navigating to: $route');
              context.go(route);
              break;
            case 1:
              context.go('/feed');
              break;
            case 2:
              context.go('/messages');
              break;
            case 3:
              context.go('/merch');
              break;
            case 4:
              final route = isBeneficiary ? '/beneficiary/profile' : '/profile';
              print('[MainLayout] Navigating to: $route');
              context.go(route);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Merch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
