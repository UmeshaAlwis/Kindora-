import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import '../dashboard/ui/dashboard_screen.dart';

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

  static const Color primaryColor = Color(0xFF0C0C79);

  /// EMAIL LOGIN
  Future<void> login() async {

    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
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

        case 'network-request-failed':
          message = "Check your internet connection.";
          break;

        default:
          message = e.message ?? e.code;

      }

      _showSnackBar(message, Colors.red);

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

  /// GOOGLE LOGIN (POPUP METHOD)
  Future<void> signInWithGoogle() async {

    if (isLoading) return;

    setState(() => isLoading = true);

    try {

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      final userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      if (userCredential.user != null && mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );

      }

    } on FirebaseAuthException catch (e) {

      debugPrint("Google error: ${e.code}");
      debugPrint("Google message: ${e.message}");

      _showSnackBar(
        e.message ?? "Google sign-in failed",
        Colors.red,
      );

    } catch (e) {

      debugPrint("Google login error: $e");

      _showSnackBar(
        "Google sign-in failed",
        Colors.red,
      );

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword() async {

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Enter your email first.", Colors.orange);
      return;
    }

    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      _showSnackBar("Password reset email sent.", Colors.green);

    } on FirebaseAuthException catch (e) {

      _showSnackBar(
        e.message ?? e.code,
        Colors.red,
      );

    }
  }

  /// SNACKBAR
  void _showSnackBar(String message, Color color) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 400,
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
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(

          child: Column(

            children: [

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 30),

              /// EMAIL
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

              /// PASSWORD
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
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 16),

              /// LOGIN BUTTON
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              /// GOOGLE LOGIN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  icon: Image.network(
                    "https://developers.google.com/identity/images/g-logo.png",
                    height: 20,
                  ),

                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: primaryColor),
                  ),

                  onPressed: isLoading ? null : signInWithGoogle,
                ),
              ),

              const SizedBox(height: 16),

              /// SIGNUP
              TextButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );

                },
                child: const Text(
                  'Don’t have an account? Sign Up',
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}