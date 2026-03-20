import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/app_env.dart';

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

  final Color primaryColor = const Color(0xFF0C0C79);
  final Color accentColor = const Color(0xFFFF751F);

  String passwordStrength = "";
  Color strengthColor = Colors.grey;

  final Map<String, String> roleOptions = {
    'donor': 'Donor - Support Causes',
    'charity': 'Volunteer - Join campaigns',
    'beneficiary': 'Beneficiary - Receive Support',
  };

  void checkPasswordStrength(String password) {
    if (password.length < 6) {
      passwordStrength = "Weak";
      strengthColor = Colors.red;
    } else if (password.length < 10) {
      passwordStrength = "Medium";
      strengthColor = Colors.orange;
    } else if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      passwordStrength = "Strong";
      strengthColor = Colors.green;
    } else {
      passwordStrength = "Medium";
      strengthColor = Colors.orange;
    }
  }

  // EMAIL SIGNUP
  Future<void> signup() async {
    print('===== SIGNUP STARTED =====');
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedRole.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      print('About to create Firebase user...');
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

        // Call backend API to sync user to Supabase
        print('===== NOW CALLING BACKEND API =====');
        print('[Signup] Backend URL: ${AppEnv.apiBaseUrl}/auth/register');
        await _registerWithBackend(email, password, user.uid, selectedRole);
        print('===== BACKEND CALL COMPLETED =====');
      }

      print('Signing out Firebase user...');
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showSnackBar(
        "Verification email sent. Please check your inbox.",
        Colors.green,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      _showSnackBar(e.message ?? "Signup failed.", Colors.red);
    } catch (e) {
      print('[Signup] ERROR CAUGHT: $e');
      _showSnackBar("Something went wrong: $e", Colors.red);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
    print('===== SIGNUP ENDED =====');
  }

  /// Call backend API to register user
  Future<void> _registerWithBackend(
      String email, String password, String firebaseUid, String role) async {
    try {
      final backendUrl = '${AppEnv.apiBaseUrl}/auth/register';
      print('[Backend] POST $backendUrl');

      final payload = {
        'email': email,
        'password': password,
        'full_name': email.split('@')[0],
        'role': role,
        'firebase_uid': firebaseUid,
      };

      final response = await http
          .post(
            Uri.parse(backendUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      print('[Backend] Response status: ${response.statusCode}');
      print('[Backend] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[Backend] ✓ User registered successfully');
      } else {
        throw Exception('Backend returned ${response.statusCode}');
      }
    } catch (e) {
      print('[Backend] ✗ Error: $e');
      rethrow;
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

      _showSnackBar(e.message ?? "Google sign-up failed.", Colors.red);
    } catch (_) {
      _showSnackBar("Something went wrong.", Colors.red);
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
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                      color: passwordsMatch ? Colors.green : Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ROLE DROPDOWN
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

              // ALREADY HAVE ACCOUNT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
