import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kindora/features/auth/ui/login_screen.dart';
import 'package:kindora/features/dashboard/ui/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),

      builder: (context, snapshot) {

        /// LOADING STATE
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// USER LOGGED IN
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        /// USER NOT LOGGED IN
        return const LoginScreen();
      },
    );
  }
}