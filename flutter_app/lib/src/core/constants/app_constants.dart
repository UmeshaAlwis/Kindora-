// Application Constants
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const String apiVersion = 'v1';
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';

  // Donation Settings
  static const double minimumDonation = 10.0;
  static const double maximumDonation = 100000.0;
  static const List<double> suggestedAmounts = [10, 25, 50, 100, 500];

  // Pagination
  static const int pageSize = 20;

  // Features
  static const bool enableNotifications = true;
  static const bool enableMessaging = true;
  static const bool enableGamification = true;
  static const bool enableMerchandise = true;

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'si', 'ta'];

  // Roles
  static const String roleDonor = 'donor';
  static const String roleCharity = 'charity';
  static const String roleAdmin = 'admin';
  static const String roleBeneficiary = 'beneficiary';
}
