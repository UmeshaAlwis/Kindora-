import 'package:flutter/material.dart';

/// Kindora brand palette — use these instead of scattered hex colors.
abstract final class AppColors {
  static const Color primaryBlue = Color(0xFF0C0C79);
  static const Color primaryOrange = Color(0xFFFF751F);

  /// Darker blue for gradients / depth (derived from primary blue).
  static const Color blueDeep = Color(0xFF05053A);

  /// Light tints for surfaces (blue / orange families).
  static const Color blueSurface = Color(0xFFEEF0FF);
  static const Color orangeSurface = Color(0xFFFFF4ED);

  /// Neutrals (minimal palette outside brand).
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF5C6378);
  static const Color border = Color(0xFFE2E4EC);
  static const Color scaffoldLight = Color(0xFFF5F6FA);

  /// Single semantic error (avoid extra greens/ambers in UI).
  static const Color error = Color(0xFFC62828);

  /// Gradient pairs for headers / FABs (brand only).
  static const List<Color> heroGradient = [primaryBlue, blueDeep];
  static const List<Color> accentGradient = [primaryBlue, primaryOrange];
}
