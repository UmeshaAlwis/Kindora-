/// Application configuration constants
class AppConfig {
  // API Configuration
  // Note: Use AppEnv.apiBaseUrl for the actual API base URL with env support
  static const String apiBaseUrl = 'http://localhost:5001/api';
  static const int apiTimeoutSeconds = 30;

  // Firebase Configuration
  static const String firebaseProjectId = 'kindora-project-id';

  // App Configuration
  static const String appName = 'Kindora';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableNotifications = true;
}
