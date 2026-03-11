import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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

  final Color primaryColor = const Color(0xFF0C0C79);

  String passwordStrength = "";
  Color strengthColor = Colors.grey;

  /// PASSWORD STRENGTH CHECK
void checkPasswordStrength(String password) {

  if (password.isEmpty) {
    passwordStrength = "";
    strengthColor = Colors.grey;
    return;
  }

  int score = 0;

  // length score
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;

  // lowercase
  if (RegExp(r'[a-z]').hasMatch(password)) score++;

  // uppercase
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;

  // numbers
  if (RegExp(r'[0-9]').hasMatch(password)) score++;

  // symbols (ANY special character)
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]~`]').hasMatch(password)) score++;

  if (score <= 2) {
    passwordStrength = "Weak";
    strengthColor = Colors.red;
  } 
  else if (score <= 4) {
    passwordStrength = "Medium";
    strengthColor = Colors.orange;
  } 
  else {
    passwordStrength = "Strong";
    strengthColor = Colors.green;
  }
}

  /// SIGNUP
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

    if (passwordStrength == "Weak") {
      _showSnackBar(
        "Password too weak. Use uppercase, lowercase, number and symbol.",
        Colors.orange,
      );
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

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showSnackBar(
        "Verification email sent. Please check your inbox.",
        Colors.green,
      );

      context.go('/login');

    } on FirebaseAuthException catch (e) {

      String message;

      switch (e.code) {

        case 'email-already-in-use':
          message = "An account already exists with this email.";
          break;

        case 'invalid-email':
          message = "The email address is invalid.";
          break;

        case 'weak-password':
          message = "Password should be at least 6 characters.";
          break;

        case 'network-request-failed':
          message = "Network error. Please check your internet.";
          break;

        default:
          message = e.message ?? "Signup failed.";
      }

      _showSnackBar(message, Colors.red);

    } catch (_) {
      _showSnackBar("Unexpected error occurred.", Colors.red);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// SNACKBAR
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
                    "Password Strength: $passwordStrength",
                    style: TextStyle(
                      color: strengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
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

              /// SIGN UP BUTTON
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
                      ? const CircularProgressIndicator(color: Colors.white)
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

              const SizedBox(height: 20),

              /// SIGN IN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("Already have an account? "),

                  GestureDetector(
                    onTap: () {
                      context.go('/login');
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