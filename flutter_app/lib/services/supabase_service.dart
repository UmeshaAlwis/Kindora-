import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal() {
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  /// Get Supabase client instance
  static SupabaseClient get supabaseClient => Supabase.instance.client;

  /// Get authenticated user ID (from Firebase or Supabase)
  String? get userId {
    try {
      // Try to get from Supabase auth first
      final supabaseUser = _client.auth.currentUser;
      return supabaseUser?.id;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => userId != null;
}
