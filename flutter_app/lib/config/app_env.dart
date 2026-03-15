import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  /// Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Stripe Configuration (Public Key Only - Safe for Frontend)
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  /// API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001/api';

  /// Backend Payment Endpoints
  static String get stripeCreateIntentUrl => '$apiBaseUrl/donations/stripe/create-intent';
  
  static String get stripeConfirmPaymentUrl => '$apiBaseUrl/donations/stripe/confirm-payment';

  /// Validation
  static bool isConfigured() {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        stripePublishableKey.isNotEmpty;
  }

  /// Debug Info
  static String getConfigInfo() {
    return '''
Kindora App Configuration:
  Supabase URL: ${supabaseUrl.replaceRange(8, supabaseUrl.length - 15, '***')}
  Stripe Key: ${stripePublishableKey.replaceRange(7, stripePublishableKey.length - 5, '***')}
  API Base: $apiBaseUrl
  Status: ${isConfigured() ? '✓ Configured' : '✗ Missing Config'}
    ''';
  }
}
