import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool isGoogleLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String passwordStrength = "";
  Color strengthColor = Colors.grey;

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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
      }

      // Sign out so AuthGate returns to login
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showSnackBar(
        "Verification email sent. Please check your inbox.",
        Colors.green,
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Signup failed.", Colors.red);
    } catch (_) {
      _showSnackBar("Something went wrong.", Colors.red);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // GOOGLE SIGNUP
  Future<void> signUpWithGoogle() async {
    if (isGoogleLoading) return;

    setState(() => isGoogleLoading = true);

    try {
      final googleProvider = GoogleAuthProvider();

      // 🔥 Force Google account chooser
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // AuthGate will redirect automatically

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Google sign-up failed.", Colors.red);
    } catch (_) {
      _showSnackBar("Something went wrong.", Colors.red);
    }

    if (mounted) {
      setState(() => isGoogleLoading = false);
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
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Join Kindora',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
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

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
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
                      color:
                          passwordsMatch ? Colors.green : Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
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
                      : const Text('Sign Up'),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: isGoogleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Sign up with Google"),
                  onPressed:
                      isGoogleLoading ? null : signUpWithGoogle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}