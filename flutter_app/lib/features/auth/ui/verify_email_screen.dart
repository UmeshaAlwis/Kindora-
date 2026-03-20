import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _startAutoVerificationCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startAutoVerificationCheck() {
    _autoCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          timer.cancel();
          return;
        }

        await user.reload();

        final refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser != null && refreshedUser.emailVerified) {
          timer.cancel();

          // 🔥 Force auth refresh
          await refreshedUser.getIdToken(true);

          // 🔥 Do nothing else
          // AuthGate will automatically rebuild and show Dashboard
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.email ?? "",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "We are automatically checking for verification...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}