import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/home/home_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(), // 🔥 IMPORTANT
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const HomeScreen();
        }

        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}