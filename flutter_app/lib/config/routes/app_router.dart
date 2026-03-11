import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layouts/app_shell.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/profile/ui/profile_page.dart';

final router = GoRouter(
  initialLocation: '/dashboard',

  routes: [

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          child: child,
          location: state.location,
        );
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

      ],
    ),

  ],
);