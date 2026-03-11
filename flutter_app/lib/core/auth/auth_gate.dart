import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      // THIS IS THE IMPORTANT CHANGE
      stream: FirebaseAuth.instance.idTokenChanges(),

      builder: (context, snapshot) {

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User logged in
        if (snapshot.data != null) {
          return const DashboardScreen();
        }

        // User not logged in
        return const LoginScreen();
      },
    );
  }
}