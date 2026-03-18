import 'package:flutter/material.dart';

class KindoraColors {
  //primary brand palette - deep blue with orange accents
  static const Color primary = Color (0xFF0C0C79); //Primary blue
  static const Color primaryLight = Color (0xFF4040B2); //mid blue
  static const Color primarySurface = Color (0xFFEAEAF5); //very light blue

  static const Color accent = Color (0xFFFF751F); //primary orange
  static const Color accentLight = Color(0xFFFFF0E8);    // light orange bg

   //neutrals
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F6);
  static const Color border = Color(0xFFE2E2EE);

    //text
  static const Color textPrimary = Color(0xFFE2E2EE);
  static const Color textSecondary = Color(0xFF5C5C8A);
  static const Color textHint = Color(0xFFA0A0C4);

    //chat bubble
  static const Color bubbleMe = Color(0xFF0C0C79);
  static const Color bubbleThem = Color(0xFFFFFFFF);
  static const Color bubbleMeText = Color(0xFFFFFFFF);
  static const Color bubbleThemText = Color(0xFF0C0C2B);

  //status
  static const Color online = Color(0xFF34C759);
  static const Color unreadBadge = Color(0xFFFF751F);
 
}

class KindoraTheme{
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KindoraColors.primary,
      brightness: Brightness.light,
      background: KindoraColors.background,
      surface: KindoraColors.surface,
    ),

    scaffoldBackgroundColor: KindoraColors.background,
    fontFamily: 'Nunito', //add to pubspace if desired; falls back to default
    appBarTheme: const AppBarTheme(
      backgroundColor: KindoraColors.surface,
      foregroundColor: KindoraColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KindoraColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  );
}