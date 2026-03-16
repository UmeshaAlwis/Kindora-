import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/chat/ui/chat_assistant_button.dart';

/// Main layout wrapper with persistent bottom navigation bar and chat assistant
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  int _getSelectedIndex(String location) {
    // Beneficiary routes map to Home (index 0)
    if (location.startsWith('/beneficiary/dashboard')) return 0;
    if (location.startsWith('/beneficiary/profile')) return 4;
    if (location.startsWith('/beneficiary/create-campaign')) return 0;
    if (location.startsWith('/beneficiary/campaign')) return 0;
    if (location.startsWith('/beneficiary')) return 0;

    // Donor routes
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/merch')) return 3;
    if (location.startsWith('/profile')) return 4;

    // Default to Home
    return 0;
  }

  Future<bool> _isBeneficiaryUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return false;

      final supabase = Supabase.instance.client;
      final userResponse = await supabase
          .from('users')
          .select('role')
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      if (userResponse == null) return false;

      final role = userResponse['role'] as String?;
      debugPrint('[MainLayout] User role from database: $role');
      return role == 'beneficiary';
    } catch (e) {
      debugPrint('[MainLayout] Error checking user role: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current route location to determine active nav index
    String location = '/dashboard'; // Default fallback
    try {
      final routerState = GoRouterState.of(context);
      location = routerState.location;
    } catch (e) {
      debugPrint('[MainLayout] Error getting location: $e');
    }

    final selectedIndex = _getSelectedIndex(location);
    debugPrint(
        '[MainLayout] Location: $location, SelectedIndex: $selectedIndex');

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
        currentIndex: selectedIndex.clamp(0, 4), // Safely clamp to valid range
        onTap: (index) async {
          // Check user role from database
          final isBeneficiary = await _isBeneficiaryUser();

          print('[MainLayout] Tapped index: $index');
          print('[MainLayout] Current location: $location');
          print('[MainLayout] Is beneficiary (from DB): $isBeneficiary');

          switch (index) {
            case 0:
              final route =
                  isBeneficiary ? '/beneficiary/dashboard' : '/dashboard';
              print('[MainLayout] Navigating to: $route');
              if (context.mounted) context.go(route);
              break;
            case 1:
              if (context.mounted) context.go('/feed');
              break;
            case 2:
              if (context.mounted) context.go('/messages');
              break;
            case 3:
              if (context.mounted) context.go('/merch');
              break;
            case 4:
              final route = isBeneficiary ? '/beneficiary/profile' : '/profile';
              print('[MainLayout] Navigating to: $route');
              if (context.mounted) context.go(route);
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
