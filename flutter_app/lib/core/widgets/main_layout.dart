import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/ui/chat_assistant_button.dart';
import '../../l10n/app_localizations.dart';

/// Main layout wrapper with persistent bottom navigation bar and chat assistant
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

 
  /// Bottom nav expects index in 0..4 (strict [int] — avoid [num] from [clamp]).
  int _clampNavIndex(int index) {
    if (index < 0) return 0;
    if (index > 4) return 4;
    return index;
  }

  int _getSelectedIndex(String location) {
    // Beneficiary routes
    if (location.startsWith('/beneficiary/wallet')) return 3;
    if (location.startsWith('/beneficiary/dashboard')) return 0;
    if (location.startsWith('/beneficiary/feed')) return 1;
    if (location.startsWith('/beneficiary/messages')) return 2;
    if (location.startsWith('/beneficiary/profile')) return 4;
    if (location.startsWith('/beneficiary/create-campaign')) return 0;
    if (location.startsWith('/beneficiary/campaign')) return 0;
    if (location.startsWith('/beneficiary')) return 0;

    // Volunteer routes
    if (location.startsWith('/volunteer/joined-campaigns')) return 3;
    if (location.startsWith('/volunteer/dashboard')) return 0;
    if (location.startsWith('/volunteer/feed')) return 1;
    if (location.startsWith('/volunteer/messages')) return 2;
    if (location.startsWith('/volunteer/profile')) return 4;
    if (location.startsWith('/volunteer')) return 0;

    // Donor routes
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/merch')) return 3;
    if (location.startsWith('/profile')) return 4;

    // Default to Home
    return 0;
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

    final selectedIndex = _clampNavIndex(_getSelectedIndex(location));
    final isBeneficiary = location.startsWith('/beneficiary');
    final isVolunteer = location.startsWith('/volunteer');
    debugPrint(
        '[MainLayout] Location: $location, SelectedIndex: $selectedIndex');

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: child,
          ),
          // Chat assistant floating button
          if (!location.startsWith('/messages') &&
              !location.startsWith('/beneficiary/messages') &&
              !location.startsWith('/volunteer/messages') &&
              !location.startsWith('/merch/product'))
            const ChatAssistantButton(showBadge: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF0C0C79),
        unselectedItemColor: Colors.blueGrey,
        selectedFontSize: 15,
        unselectedFontSize: 14,
        onTap: (index) async {
          print('[MainLayout] Tapped index: $index');
          print('[MainLayout] Current location: $location');
          print('[MainLayout] Is beneficiary (resolved): $isBeneficiary');
          print('[MainLayout] Is volunteer (resolved): $isVolunteer');

          switch (index) {
            case 0:
              final route = isBeneficiary
                  ? '/beneficiary/dashboard'
                  : (isVolunteer ? '/volunteer/dashboard' : '/dashboard');
              print('[MainLayout] Navigating to: $route');
              if (context.mounted) context.go(route);
              break;
            case 1:
              if (context.mounted) {
                context.go(
                    isBeneficiary
                        ? '/beneficiary/feed'
                        : (isVolunteer ? '/volunteer/feed' : '/feed'));
              }
              break;
            case 2:
              if (context.mounted) {
                context.go(
                    isBeneficiary
                        ? '/beneficiary/messages'
                        : (isVolunteer ? '/volunteer/messages' : '/messages'));
              }
              break;
            case 3:
              if (context.mounted) {
                context.go(isBeneficiary
                    ? '/beneficiary/wallet'
                    : (isVolunteer ? '/volunteer/joined-campaigns' : '/merch'));
              }
              break;
            case 4:
              final route = isBeneficiary
                  ? '/beneficiary/profile'
                  : (isVolunteer ? '/volunteer/profile' : '/profile');
              print('[MainLayout] Navigating to: $route');
              if (context.mounted) context.go(route);
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home, color: Color(0xFF0C0C79)),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            activeIcon: Icon(Icons.rss_feed, color: Color(0xFF0C0C79)),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me, color: Color(0xFF0C0C79)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              isBeneficiary
                  ? Icons.account_balance_wallet_outlined
                  : (isVolunteer
                      ? Icons.group_add_outlined
                      : Icons.volunteer_activism_outlined),
            ),
            activeIcon: Icon(
              isBeneficiary
                  ? Icons.account_balance_wallet
                  : (isVolunteer ? Icons.group_add : Icons.volunteer_activism),
              color: const Color(0xFF0C0C79),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
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
            isBeneficiary
                ? l10n.wallet
                : (isVolunteer ? l10n.joinedCampaigns : l10n.merch),
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
