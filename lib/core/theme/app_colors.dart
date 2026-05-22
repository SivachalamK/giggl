import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color onSurface;
  final Color inputFill;
  final Color border;
  final Color error;
  final LinearGradient primaryGradient;
  final LinearGradient glassGradient;

  const AppColorScheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.onSurface,
    required this.inputFill,
    required this.border,
    required this.error,
    required this.primaryGradient,
    required this.glassGradient,
  });
}

class AppColors {
  static const electricBlue = Color(0xFF3B82F6);
  static const deepPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, deepPurple, accentPink],
  );

  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x11FFFFFF),
    ],
  );

  static final light = AppColorScheme(
    primary: electricBlue,
    secondary: deepPurple,
    background: const Color(0xFFF8FAFC),
    surface: Colors.white,
    card: Colors.white,
    onSurface: const Color(0xFF0F172A),
    inputFill: const Color(0xFFF1F5F9),
    border: const Color(0xFFE2E8F0),
    error: error,
    primaryGradient: primaryGradient,
    glassGradient: glassGradient,
  );

  static final dark = AppColorScheme(
    primary: electricBlue,
    secondary: deepPurple,
    background: const Color(0xFF0B0F1A),
    surface: const Color(0xFF151B2E),
    card: const Color(0xFF1A2238),
    onSurface: const Color(0xFFF1F5F9),
    inputFill: const Color(0xFF1E293B),
    border: const Color(0xFF334155),
    error: error,
    primaryGradient: primaryGradient,
    glassGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x22FFFFFF),
        Color(0x08FFFFFF),
      ],
    ),
  );

  static AppColorScheme of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }
}
