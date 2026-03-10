import 'package:supabase/supabase.dart';
import 'package:flutter/foundation.dart';

/// Supabase Configuration and Initialization
/// 
/// This class handles Supabase initialization when needed.
/// The app primarily uses Firebase, but Supabase can be initialized on-demand
/// for additional backend functionality (e.g., real-time databases, edge functions).
class SupabaseConfig {
  // Supabase credentials - REPLACE WITH YOUR ACTUAL CREDENTIALS
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // Singleton instance
  static SupabaseClient? _client;

  /// Check if Supabase is already initialized
  static bool get isInitialized => _client != null;

  /// Get the Supabase client instance
  /// Throws an exception if Supabase is not initialized
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.'
      );
    }
    return _client!;
  }

  /// Initialize Supabase when needed
  /// 
  /// This is called on app startup in main() if Supabase features are required.
  /// Can also be called later for lazy initialization.
  static Future<void> initialize() async {
    if (_client != null) {
      debugPrint('Supabase already initialized');
      return;
    }

    try {
      // Validate credentials before attempting initialization
      if (supabaseUrl == 'https://xxxxx.supabase.co' || 
          supabaseAnonKey == 'your-anon-key') {
        debugPrint(
          'Supabase credentials not configured. '
          'Update supabaseUrl and supabaseAnonKey in supabase_config.dart'
        );
        return;
      }

      // Initialize Supabase client
      _client = SupabaseClient(supabaseUrl, supabaseAnonKey);

      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      rethrow; // Re-throw for caller to handle if needed
    }
  }

  /// Safely access Supabase client with null safety
  /// 
  /// Returns null if not initialized, avoiding exceptions
  static SupabaseClient? tryGetClient() {
    return _client;
  }

  /// Reset Supabase initialization (useful for testing or switching users)
  static void reset() {
    _client = null;
    debugPrint('Supabase instance reset');
  }
}
