import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../features/auth/ui/login_screen.dart';
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

class _AuthenticatedGate extends ConsumerStatefulWidget {
  final User user;

  const _AuthenticatedGate({required this.user});

  @override
  ConsumerState<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends ConsumerState<_AuthenticatedGate> {
  late final Future<Map<String, dynamic>?> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _getUserRoleAndStatus(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Error fetching user data.
          // Don't immediately fall back to donor UI; instead, retry role fetch
          // and route based on what we find.
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final data = await _getUserRoleAndStatus(widget.user.uid);
              if (!context.mounted) return;

              final userRole = data?['role'] as String? ?? 'donor';
              final profileCompleted =
                  data?['profileCompleted'] as bool? ?? false;

              if (userRole == 'beneficiary') {
                if (!profileCompleted) {
                  context.go('/beneficiary/profile-completion');
                } else {
                  context.go('/beneficiary/dashboard');
                }
              } else if (userRole == 'charity') {
                context.go('/volunteer/dashboard');
              } else {
                context.go('/dashboard');
              }
            } catch (_) {
              if (!context.mounted) return;
              context.go('/dashboard');
            }
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
        } else if (userRole == 'charity') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/volunteer/dashboard');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // For donor and volunteer roles, go to regular dashboard (with bottom nav)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/dashboard');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserRoleAndStatus(String userId) async {
    try {
      print('[AuthGate DEBUG] Fetching role for Firebase UID: $userId');

      // Prefer Firebase custom claims (most reliable during initial sync).
      // This avoids briefly routing beneficiary users to donor screens.
      String? firebaseRoleClaim;
      try {
        // Force refresh so custom claims are available right after login.
        final idTokenResult = await widget.user.getIdTokenResult(true);
        final claim = idTokenResult.claims?['role'];
        if (claim is String) firebaseRoleClaim = claim;
      } catch (_) {
        firebaseRoleClaim = null;
      }

      // Give Supabase a head start to sync from Firebase (initial delay)
      print('[AuthGate DEBUG] Waiting for Supabase sync...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // Get user role from Supabase users table using firebase_uid
      final supabase = Supabase.instance.client;

      // Retry logic - Supabase sync can take a moment
      Map<String, dynamic>? profileResponse;
      int retries = 0;
      const maxRetries = 10; // Increased from 8 to 10
      const retryDelayMs = 1000; // Increased from 750ms to 1000ms (1 second)

      while (profileResponse == null && retries < maxRetries) {
        profileResponse = await supabase
            .from('users')
            .select('id, role')
            .eq('firebase_uid', userId)
            .maybeSingle();

        if (profileResponse == null && retries < maxRetries - 1) {
          print(
              '[AuthGate DEBUG] User not found in Supabase, retrying... (${retries + 1}/$maxRetries)');
          await Future.delayed(const Duration(milliseconds: retryDelayMs));
          retries++;
        } else {
          break;
        }
      }

      print('[AuthGate DEBUG] Profile response: $profileResponse');

      if (profileResponse == null) {
        print(
            '[AuthGate DEBUG] ✗ User not found in Supabase after $maxRetries retries.');

        // Fallback to Firebase claim when Supabase row isn't ready yet.
        if (firebaseRoleClaim != null) {
          final isBeneficiary = firebaseRoleClaim == 'beneficiary';
          return {
            'role': firebaseRoleClaim,
            'profileCompleted': isBeneficiary ? true : true,
          };
        }

        // Last-resort fallback.
        return {
          'role': 'donor',
          'profileCompleted': true,
        };
      }

      final supabaseUserId = profileResponse['id'] as String;
      final userRole = profileResponse['role'] as String? ?? 'donor';
      print('[AuthGate DEBUG] ✓ Successfully fetched user role: $userRole');

      // Supabase can take a moment to sync `beneficiary_details` right after login.
      // If we query once and get null, we might incorrectly route to donor UI.
      final beneficiaryRepo = BeneficiaryDetailsRepository();
      var beneficiaryDetails;
      int beneficiaryRetries = 0;
      // Keep this short to avoid long loading loops.
      const maxBeneficiaryRetries = 5;
      const beneficiaryRetryDelayMs = 600;

      while (beneficiaryDetails == null &&
          beneficiaryRetries < maxBeneficiaryRetries) {
        beneficiaryDetails =
            await beneficiaryRepo.getBeneficiaryDetails(supabaseUserId);

        if (beneficiaryDetails != null) break;

        if (beneficiaryRetries < maxBeneficiaryRetries - 1) {
          print(
              '[AuthGate DEBUG] beneficiary_details not ready yet, retrying... (${beneficiaryRetries + 1}/$maxBeneficiaryRetries)');
          await Future.delayed(
            const Duration(milliseconds: beneficiaryRetryDelayMs),
          );
        }
        beneficiaryRetries++;
      }

      final hasBeneficiaryDetails = beneficiaryDetails != null;

      // If claims weren't ready earlier, try one more refresh after waiting.
      if (firebaseRoleClaim == null) {
        try {
          final idTokenResult = await widget.user.getIdTokenResult(true);
          final claim = idTokenResult.claims?['role'];
          if (claim is String) firebaseRoleClaim = claim;
        } catch (_) {}
      }

      // Resolve role deterministically during login:
      // - Trust Firebase claim for both `beneficiary` and `charity` (volunteer).
      // - If Firebase claim isn't available yet, fall back to beneficiary_details existence.
      // - Otherwise use Supabase users.role.
      final resolvedRole = firebaseRoleClaim == 'beneficiary'
          ? 'beneficiary'
          : (firebaseRoleClaim == 'charity'
              ? 'charity'
              : (hasBeneficiaryDetails ? 'beneficiary' : userRole));

      if (resolvedRole == 'beneficiary') {
        final profileCompleted = beneficiaryDetails?.profileCompleted ?? true;

        return {
          'role': resolvedRole,
          'profileCompleted': profileCompleted,
        };
      }

      return {
        'role': resolvedRole,
        'profileCompleted': true,
      };
    } catch (e) {
      // Error getting user role and status, proceed with Firebase claim if possible.
      print('[AuthGate ERROR] Error: $e');
      print('[AuthGate ERROR] Stack: ${StackTrace.current}');

      String? firebaseRoleClaim;
      try {
        final idTokenResult = await widget.user.getIdTokenResult();
        final claim = idTokenResult.claims?['role'];
        if (claim is String) firebaseRoleClaim = claim;
      } catch (_) {
        firebaseRoleClaim = null;
      }

      return {
        'role': firebaseRoleClaim ?? 'donor',
        'profileCompleted': true,
      };
    }
  }
}
