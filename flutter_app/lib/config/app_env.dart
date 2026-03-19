import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  /// Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001/api';

  /// Validation
  static bool isConfigured() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  /// Debug Info
  static String getConfigInfo() {
    return '''
Kindora App Configuration:
  Supabase URL: ${supabaseUrl.replaceRange(8, supabaseUrl.length - 15, '***')}
  API Base: $apiBaseUrl
  Status: ${isConfigured() ? '✓ Configured' : '✗ Missing Required Config'}
    ''';
  }
}
