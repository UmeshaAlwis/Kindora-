import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/signup_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/settings/ui/settings_page.dart';
import '../../features/campaign/ui/campaign_home_page.dart';

import '../../core/widgets/auth_gate.dart';
import '../../core/widgets/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [

      /// HOME
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      /// AUTH GATE
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthGate(),
      ),

      /// LOGIN
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// SIGNUP
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      /// MAIN APP (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [

          /// DASHBOARD
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          /// CAMPAIGNS
          GoRoute(
            path: '/campaigns',
            name: 'campaigns',
            builder: (context, state) => const CampaignHomePage(),
          ),

          /// PROFILE
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          /// SETTINGS
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),

        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text(
          'Route not found: ${state.location}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
}