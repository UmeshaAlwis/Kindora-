import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/chat/ui/chat_assistant_button.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
          if (!location.startsWith('/messages'))
            const ChatAssistantButton(showBadge: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.clamp(0, 4), // Safely clamp to valid range
        selectedItemColor: const Color(0xFF0C0C79),
        unselectedItemColor: Colors.blueGrey,
        selectedFontSize: 15,
        unselectedFontSize: 14,
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
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home, color: Color(0xFF0C0C79)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            activeIcon: Icon(Icons.rss_feed, color: Color(0xFF0C0C79)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me, color: Color(0xFF0C0C79)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon:
                Icon(Icons.volunteer_activism, color: Color(0xFF0C0C79)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Color(0xFF0C0C79)),
            label: '',
          ),
        ].asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final labels = [
            l10n.home,
            l10n.feed,
            l10n.messages,
            l10n.merch,
            l10n.profile,
          ];
          return BottomNavigationBarItem(
            icon: item.icon,
            activeIcon: item.activeIcon,
            label: labels[i],
          );
        }).toList(),
      ),
    );
  }
}
