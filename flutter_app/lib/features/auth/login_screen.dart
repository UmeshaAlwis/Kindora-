import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final Color primaryColor = AppColors.primaryBlue;
  final Color accentColor = AppColors.primaryOrange;

  // EMAIL LOGIN
  Future<void> login() async {

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields", AppColors.primaryOrange);
      return;
    }

    setState(() => isLoading = true);

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show success message
      _showSnackBar("Login successful!", AppColors.primaryBlue);

      // Navigate to Dashboard after successful login
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email.";
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = "Incorrect email or password.";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Try again later.";
          break;

        default:
          message = e.message ?? "Login failed.";
      }

      _showSnackBar(message, AppColors.error);

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

  // GOOGLE LOGIN
  Future<void> signInWithGoogle() async {

    try {

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      await FirebaseAuth.instance.signInWithPopup(googleProvider);

    } on FirebaseAuthException catch (e) {

      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return;
      }

      _showSnackBar(e.message ?? "Google sign-in failed.", AppColors.error);

    } catch (_) {

      _showSnackBar("Google sign-in failed.", AppColors.error);

    }
  }

  // RESET PASSWORD
  Future<void> resetPassword() async {

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Enter your email first.", AppColors.primaryOrange);
      return;
    }

    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      _showSnackBar("Password reset email sent.", AppColors.primaryBlue);

    } catch (_) {

      _showSnackBar("Failed to send reset email.", AppColors.error);

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Login to Kindora',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(

          child: Column(

            children: [

              Text(
                'Welcome Back',
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
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: resetPassword,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // LOGIN BUTTON
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

                  onPressed: isLoading ? null : login,

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
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // GOOGLE LOGIN
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
                    "Sign in with Google",
                    style: TextStyle(color: primaryColor),
                  ),

                  onPressed: signInWithGoogle,
                ),
              ),

              const SizedBox(height: 16),

              // SIGNUP
              TextButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );

                },
                child: Text(
                  'Don’t have an account? Sign Up',
                  style: TextStyle(color: primaryColor),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}