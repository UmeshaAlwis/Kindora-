enum Environment { development, production }

class AppConfig {
  static const Environment environment = Environment.development;

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://localhost:5000/api';
      case Environment.production:
        return 'https://api.kindora.com/api';
    }
  }

  // Firebase Configuration
  static const String firebaseProjectId = 'kindora-project';
  
  // App Configuration
  static const String appName = 'Kindora';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enableOfflineMode = true;
}
