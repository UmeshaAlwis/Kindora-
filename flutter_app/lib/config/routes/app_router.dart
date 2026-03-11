import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kindora/features/auth/ui/login_screen.dart';
import 'package:kindora/features/auth/ui/signup_screen.dart';
import 'package:kindora/features/home/ui/home_screen.dart';
import 'package:kindora/features/dashboard/ui/dashboard_screen.dart';
import 'package:kindora/features/profile/ui/profile_page.dart';
import 'package:kindora/features/settings/ui/settings_page.dart';
import 'package:kindora/features/campaign/ui/campaign_home_page.dart';

import 'package:kindora/core/auth/auth_gate.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [

      /// AUTH GATE
      GoRoute(
        path: '/',
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