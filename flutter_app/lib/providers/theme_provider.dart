import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme State Notifier
class ThemeStateNotifier extends StateNotifier<bool> {
  ThemeStateNotifier(bool initialState) : super(initialState) {
    _loadPreference();
  }

  /// Load the dark mode preference from SharedPreferences
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark;
  }

  /// Toggle dark mode and save preference
  Future<void> toggleDarkMode(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}

/// Theme Provider - provides current dark mode state
final themeProvider = StateNotifierProvider<ThemeStateNotifier, bool>((ref) {
  return ThemeStateNotifier(false);
});
