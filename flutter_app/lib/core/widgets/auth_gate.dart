import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../repositories/supabase_repositories.dart';

/// Auth Gate - Routes user based on authentication status and role
class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - check their role and profile status
          return _AuthenticatedGate(user: snapshot.data!);
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

class _AuthenticatedGate extends ConsumerWidget {
  final User user;

  const _AuthenticatedGate({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserRoleAndStatus(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Error fetching user data, proceed with default role
          return const HomeScreen();
        }

        final data = snapshot.data;
        final userRole = data?['role'] as String? ?? 'donor';
        final profileCompleted = data?['profileCompleted'] as bool? ?? false;

        print('[AuthGate DEBUG] User role: $userRole');
        print('[AuthGate DEBUG] Profile completed: $profileCompleted');
        print('[AuthGate DEBUG] All data: $data');

        // Route based on role
        if (userRole == 'beneficiary') {
          if (!profileCompleted) {
            // Redirect beneficiary to profile completion screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/beneficiary/profile-completion');
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Redirect to beneficiary dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/beneficiary/dashboard');
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }

        // For donor and volunteer roles, go to regular dashboard
        return const HomeScreen();
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserRoleAndStatus(String userId) async {
    try {
      print('[AuthGate DEBUG] Fetching role for Firebase UID: $userId');

      // Get user role from Supabase users table using firebase_uid
      final supabase = Supabase.instance.client;
      final profileResponse = await supabase
          .from('users')
          .select('id, role')
          .eq('firebase_uid', userId)
          .maybeSingle();

      print('[AuthGate DEBUG] Profile response: $profileResponse');

      if (profileResponse == null) {
        print('[AuthGate DEBUG] User not found in Supabase');
        return null;
      }

      final supabaseUserId = profileResponse['id'] as String;
      final userRole = profileResponse['role'] as String? ?? 'donor';
      print('[AuthGate DEBUG] User role from DB: $userRole');

      // If beneficiary, check if profile is completed
      if (userRole == 'beneficiary') {
        print(
            '[AuthGate DEBUG] User is beneficiary, checking profile completion...');
        final beneficiaryDetails = BeneficiaryDetailsRepository()
            .getBeneficiaryDetails(supabaseUserId);
        final details = await beneficiaryDetails;
        print('[AuthGate DEBUG] Beneficiary details: $details');
        return {
          'role': userRole,
          'profileCompleted': details != null && details.profileCompleted,
        };
      }

      return {
        'role': userRole,
        'profileCompleted': true,
      };
    } catch (e) {
      // Error getting user role and status, proceed with default role
      print('[AuthGate ERROR] Error: $e');
      print('[AuthGate ERROR] Stack: ${StackTrace.current}');
      return null;
    }
  }
}
