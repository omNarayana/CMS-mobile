import 'package:flutter/material.dart';

/// Design tokens and theme configuration for the Student Academic Portal.
class AcademicTheme {
  // Brand & Academic Colors
  static const Color primary = Color(0xFF4338CA); // Deep Royal Indigo
  static const Color primaryDark = Color(0xFF312E81);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color accent = Color(0xFF06B6D4); // Vibrant Cyan
  static const Color violetAccent = Color(0xFF8B5CF6);

  // Status & Grade Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Rose/Coral
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color cardDark = Color(0xFF151D2E);
  static const Color cardElevatedDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF26334D);

  // Card Shadow & Radius
  static BorderRadius borderRadiusSm = BorderRadius.circular(10.0);
  static BorderRadius borderRadiusMd = BorderRadius.circular(16.0);
  static BorderRadius borderRadiusLg = BorderRadius.circular(24.0);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  // Gradients
  static const LinearGradient academicHeaderGradient = LinearGradient(
    colors: [Color(0xFF2E1065), Color(0xFF3730A3), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creditBadgeGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: cardLight,
        error: danger,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        centerTitle: false,
      ),
      cardTheme:  CardThemeData(   // or CardThemeData(
      color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
    );
  }

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accent,
        surface: cardDark,
        error: danger,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        centerTitle: false,
      ),
      cardTheme:  CardThemeData(   // or CardThemeData(
      color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMd,
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
    );
  }
}
