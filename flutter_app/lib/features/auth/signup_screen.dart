import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_env.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String selectedRole = 'donor';

  final Color primaryColor = AppColors.primaryBlue;
  final Color accentColor = AppColors.primaryOrange;

  String passwordStrength = "";
  Color strengthColor = Colors.grey;

  // Role options for display and mapping
  final Map<String, String> roleOptions = {
    'donor': 'Donor - Support Causes',
    'charity': 'Volunteer - Join campaigns',
    'beneficiary': 'Beneficiary - Receive Support',
  };

  void checkPasswordStrength(String password) {
    if (password.length < 6) {
      passwordStrength = "Weak";
      strengthColor = AppColors.error;
    } else if (password.length < 10) {
      passwordStrength = "Medium";
      strengthColor = AppColors.primaryOrange;
    } else if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      passwordStrength = "Strong";
      strengthColor = AppColors.primaryBlue;
    } else {
      passwordStrength = "Medium";
      strengthColor = AppColors.primaryOrange;
    }
  }

  // EMAIL SIGNUP
  Future<void> signup() async {
    print('===== SIGNUP STARTED =====');
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    print('Email: $email');
    print('Password length: ${password.length}');

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedRole.isEmpty) {
      _showSnackBar("Please fill all fields", AppColors.primaryOrange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match", AppColors.primaryOrange);
      return;
    }

    setState(() => isLoading = true);

    try {
      print('About to create Firebase user...');
      // Step 1: Create user in Firebase
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase user created: ${userCredential.user?.uid}');

      final user = userCredential.user;

      if (user != null) {
        print('Sending verification email...');
        await user.sendEmailVerification();

        // Step 2: Call backend API to sync user to Supabase
        print('===== NOW CALLING BACKEND API =====');
        print(
            '[Signup] Backend URL will be: ${AppEnv.apiBaseUrl}/auth/register');
        await _registerWithBackend(email, password, user.uid, selectedRole);
        print('===== BACKEND CALL COMPLETED =====');
      }

      print('Signing out Firebase user...');
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showSnackBar(
        "Verification email sent. Please check your inbox.",
        AppColors.primaryBlue,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      _showSnackBar(e.message ?? "Signup failed.", AppColors.error);
    } catch (e) {
      print('[Signup] ERROR CAUGHT: $e');
      print('[Signup] Error type: ${e.runtimeType}');
      _showSnackBar("Something went wrong: $e", AppColors.error);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
    print('===== SIGNUP ENDED =====');
  }

  /// Call backend API to register user and sync to Supabase
  Future<void> _registerWithBackend(
      String email, String password, String firebaseUid, String role) async {
    try {
      final backendUrl = '${AppEnv.apiBaseUrl}/auth/register';
      print('[Signup] Backend URL: $backendUrl');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': email.split('@')[0],
          'role': role,
          'phone_number': null,
        }),
      );

      print('[Signup] Backend response: ${response.statusCode}');
      print('[Signup] Backend body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[Signup] User registered successfully in backend');
      } else {
        print(
            '[Signup] Backend returned ${response.statusCode}: ${response.body}');
        throw Exception('Backend registration failed: ${response.body}');
      }
    } catch (e) {
      print('[Signup] Backend registration error: $e');
      throw Exception('Failed to sync with backend: $e');
    }
  }

  // GOOGLE SIGNUP
  Future<void> signUpWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return;
      }

      _showSnackBar(e.message ?? "Google sign-up failed.", AppColors.error);
    } catch (_) {
      _showSnackBar("Something went wrong.", AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch =
        passwordController.text == confirmPasswordController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Join Kindora',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 30),

            // EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PASSWORD
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              onChanged: (value) {
                setState(() {
                  checkPasswordStrength(value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 6),

            if (passwordController.text.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Strength: $passwordStrength",
                  style: TextStyle(
                    color: strengthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // CONFIRM PASSWORD
            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 6),

            if (confirmPasswordController.text.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  passwordsMatch
                      ? "Passwords match ✓"
                      : "Passwords do not match",
                  style: TextStyle(
                    color: passwordsMatch ? AppColors.primaryBlue : AppColors.error,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ROLE DROPDOWN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select your role'),
                items: roleOptions.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // SIGNUP BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : signup,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // GOOGLE SIGNUP
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.login, color: primaryColor),
                label: Text(
                  "Sign up with Google",
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: signUpWithGoogle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
