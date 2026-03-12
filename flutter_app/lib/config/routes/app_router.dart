import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layouts/app_shell.dart';

import '../../features/home/ui/home_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/signup_screen.dart'; // ADD
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../features/settings/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',

  routes: [

    /// HOME
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    /// LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// SIGNUP
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    /// MAIN APP
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },

      routes: [

        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),

        GoRoute(
          path: '/feed',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Feed Page")),
          ),
        ),

        GoRoute(
          path: '/messages',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Messages Page")),
          ),
        ),

        GoRoute(
          path: '/merch',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Merch Page")),
          ),
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),

        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

      ],
    ),
  ],
);