import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/signup_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/campaign/ui/campaign_home_page.dart';
import '../../features/feed/ui/feed_page.dart';
import '../../features/messages/ui/messages_page.dart';
import '../../features/merch/ui/merch_page.dart';
import '../../features/beneficiary/ui/beneficiary_profile_completion_screen.dart';
import '../../features/beneficiary/ui/beneficiary_dashboard_screen.dart';
import '../../features/beneficiary/ui/beneficiary_profile_screen.dart';
import '../../features/beneficiary/ui/beneficiary_create_campaign_screen.dart';
import '../../features/beneficiary/ui/beneficiary_campaign_detail_screen.dart';
import '../../core/widgets/auth_gate.dart';
import '../../core/widgets/main_layout.dart';

/// App Routes Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    routes: [
      // Authentication routes (without bottom nav)
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Beneficiary routes (without main layout bottom nav)
      GoRoute(
        path: '/beneficiary/profile-completion',
        name: 'beneficiary-profile-completion',
        builder: (context, state) => const BeneficiaryProfileCompletionScreen(),
      ),

      // Beneficiary routes with main layout
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // Main app routes
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) => const MessagesPage(),
          ),
          GoRoute(
            path: '/merch',
            name: 'merch',
            builder: (context, state) => const MerchPage(),
          ),
          GoRoute(
            path: '/campaigns',
            name: 'campaigns',
            builder: (context, state) => const CampaignHomePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // Beneficiary dashboard routes
          GoRoute(
            path: '/beneficiary/dashboard',
            name: 'beneficiary-dashboard',
            builder: (context, state) => const BeneficiaryDashboardScreen(),
          ),
          GoRoute(
            path: '/beneficiary/profile',
            name: 'beneficiary-profile',
            builder: (context, state) => const BeneficiaryProfileScreen(),
          ),
          GoRoute(
            path: '/beneficiary/create-campaign',
            name: 'beneficiary-create-campaign',
            builder: (context, state) =>
                const BeneficiaryCreateCampaignScreen(),
          ),
          GoRoute(
            path: '/beneficiary/campaigns',
            name: 'beneficiary-campaigns',
            builder: (context, state) => const BeneficiaryDashboardScreen(),
          ),
          GoRoute(
            path: '/beneficiary/campaign/:id',
            name: 'beneficiary-campaign-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BeneficiaryCampaignDetailScreen(campaignId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.location}'),
      ),
    ),
  );
}
