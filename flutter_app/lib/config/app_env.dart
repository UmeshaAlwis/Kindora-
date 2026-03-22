import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  /// Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Stripe Configuration (Public Key Only - Safe for Frontend)
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  /// API Configuration
  ///
  /// **Port:** Must match backend `PORT` (see `backend/.env.example`, default `5000`).
  ///
  /// **Host:** `10.0.2.2` reaches the dev machine from the **Android emulator**
  /// only. For **web, iOS, Windows, macOS, Linux** we rewrite `10.0.2.2` (and
  /// `0.0.0.0`) to `localhost` so one `.env` works for emulator + Chrome.
  /// **Native Android** keeps `10.0.2.2` unchanged.
  static String get apiBaseUrl {
    const fallback = 'http://localhost:5000/api';
    final raw = dotenv.env['API_BASE_URL']?.trim();
    var base = (raw != null && raw.isNotEmpty) ? raw : fallback;

    final isNativeAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (!isNativeAndroid) {
      base = base.replaceAll('10.0.2.2', 'localhost');
      base = base.replaceAll('0.0.0.0', 'localhost');
    }
    return base;
  }

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
    String mask(String value, {int head = 12}) {
      if (value.isEmpty) return '(empty)';
      if (value.length <= head + 4) return '***';
      return '${value.substring(0, head)}***';
    }

    return '''
Kindora App Configuration:
  Supabase URL: ${mask(supabaseUrl)}
  Stripe Key: ${mask(stripePublishableKey, head: 8)}
  API Base: $apiBaseUrl
  Status: ${isConfigured() ? '✓ Configured' : '✗ Missing Config'}
    ''';
  }
}
