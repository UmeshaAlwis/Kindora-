import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layouts/app_shell.dart';

import '../../features/home/ui/home_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/settings/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',   // 👈 Start at Home

  routes: [

    /// HOME PAGE
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    /// LOGIN PAGE
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// MAIN APP (with bottom navigation)
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },

      routes: [

        /// DASHBOARD
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),

        /// FEED
        GoRoute(
          path: '/feed',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Feed Page")),
          ),
        ),

        /// MESSAGES
        GoRoute(
          path: '/messages',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Messages Page")),
          ),
        ),

        /// MERCH
        GoRoute(
          path: '/merch',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Merch Page")),
          ),
        ),

        /// PROFILE
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),

        /// SETTINGS
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

      ],
    ),
  ],
);