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

  final Color primaryColor = const Color(0xFF0C0C79);
  final Color accentColor = const Color(0xFFFF751F);

  Future<void> login() async {

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackBar("Login successful!", Colors.green);

      if (mounted) {
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

        default:
          message = e.message ?? "Login failed.";
      }

      _showSnackBar(message, Colors.red);

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

  Future<void> signInWithGoogle() async {

    if (isLoading) return;

    setState(() => isLoading = true);

    try {

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      });

      await FirebaseAuth.instance.signInWithPopup(googleProvider);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {

      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return;
      }

      _showSnackBar(e.message ?? "Google sign-in failed.", Colors.red);

    } catch (_) {

      _showSnackBar("Google sign-in failed.", Colors.red);

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

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

    } catch (_) {

      _showSnackBar("Failed to send reset email.", Colors.red);

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
        backgroundColor: const Color(0xFF0C0C79),
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