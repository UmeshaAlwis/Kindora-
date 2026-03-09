import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const Color primaryColor = Color(0xFF0C0C79);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),

              const SizedBox(height: 16),

              // USER EMAIL
              Text(
                user?.email ?? "No email",
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 8),

              // EMAIL STATUS
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

              const SizedBox(height: 40),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}