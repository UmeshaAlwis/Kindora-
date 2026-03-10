import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/signup_screen.dart';
import 'features/dashboard/ui/dashboard_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
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

  ],
);

void main() {
  runApp(const KindoraApp());
}

class KindoraApp extends StatelessWidget {
  const KindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kindora',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}