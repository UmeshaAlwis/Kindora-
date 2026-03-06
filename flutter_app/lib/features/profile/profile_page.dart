import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),

            // User Email
            Text(
              user?.email ?? "No email",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            // Optional: Email Verified Status
            Text(
              user?.emailVerified == true
                  ? "Email Verified ✅"
                  : "Email Not Verified ❌",
              style: TextStyle(
                color: user?.emailVerified == true
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}