import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../core/navigation/kindora_app_role.dart';

/// Firebase auth stream (used to refresh role when session changes).
final firebaseAuthUserForRoleProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Resolved app role for navigation & personalization.
///
/// Uses Supabase `users.role` (`donor` | `beneficiary` | `charity`).
/// Falls back to [KindoraAppRole.donor] if unauthenticated or row missing.
///
/// For login routing, [AuthGate] still applies richer logic (Firebase claims +
/// beneficiary row). Keep this aligned when you change role rules.
final currentAppRoleProvider =
    FutureProvider.autoDispose<KindoraAppRole>((ref) async {
  final user = ref.watch(firebaseAuthUserForRoleProvider).valueOrNull;
  if (user == null) return KindoraAppRole.donor;

  final supabase = Supabase.instance.client;
  final row = await supabase
      .from('users')
      .select('role')
      .eq('firebase_uid', user.uid)
      .maybeSingle();

  return KindoraAppRoleX.fromBackendRole(row?['role'] as String?);
});
