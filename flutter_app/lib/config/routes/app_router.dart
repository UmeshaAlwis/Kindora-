import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'go_router_refresh_stream.dart';

import 'package:kindora/features/auth/ui/login_screen.dart';
import 'package:kindora/features/auth/ui/signup_screen.dart';
import 'package:kindora/features/home/ui/home_screen.dart';
import 'package:kindora/features/dashboard/ui/dashboard_screen.dart';
import 'package:kindora/features/profile/ui/profile_page.dart';
import 'package:kindora/features/settings/ui/settings_page.dart';
import 'package:kindora/features/campaign/ui/campaign_home_page.dart';

class AppRouter {

  static final GoRouter router = GoRouter(

    initialLocation: '/',

    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    redirect: (context, state) {

      final user = FirebaseAuth.instance.currentUser;

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      /// allow landing page
      if (state.matchedLocation == '/') {
        return null;
      }

      /// user not logged in
      if (user == null && !loggingIn) {
        return '/login';
      }

      /// user logged in
      if (user != null && loggingIn) {
        return '/dashboard';
      }

      return null;
    },

    routes: [

      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      GoRoute(
        path: '/campaigns',
        builder: (context, state) => const CampaignHomePage(),
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
  );
}