import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language State Notifier
class LanguageStateNotifier extends StateNotifier<Locale> {
  LanguageStateNotifier(Locale initialState) : super(initialState) {
    _loadPreference();
  }

  /// Load the language preference from SharedPreferences
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    state = Locale(languageCode);
  }

  /// Change language and save preference
  Future<void> changeLanguage(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  /// Get current language code
  String getCurrentLanguage() => state.languageCode;

  /// Get language name from code
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }
}

/// Language Provider - provides current language state
final languageProvider =
    StateNotifierProvider<LanguageStateNotifier, Locale>((ref) {
  return LanguageStateNotifier(const Locale('en'));
});

/// Supported locales
const supportedLocales = [
  Locale('en'), // English
  Locale('si'), // Sinhala
  Locale('ta'), // Tamil
];

/// Get all available languages
List<Map<String, String>> getAvailableLanguages() {
  return [
    {'code': 'en', 'name': 'English'},
    {'code': 'si', 'name': 'සිංහල'},
    {'code': 'ta', 'name': 'தமிழ்'},
  ];
}
