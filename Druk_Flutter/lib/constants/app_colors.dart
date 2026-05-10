import 'package:flutter/material.dart';

class AppColors {
  // Base Surfaces (Deep Tavern Ambience)
  static const Color surfaceDim = Color(0xFF161310);
  static const Color surfaceContainerLowest = Color(0xFF1A1714);
  static const Color surfaceContainerLow = Color(0xFF1E1B18);
  static const Color surfaceContainer = Color(0xFF231F1C);
  static const Color surfaceContainerHighest = Color(0xFF383431);
  static const Color surface = Color(0xFF161310);

  // Brand Accents (Amber & Gold)
  static const Color primary = Color(0xFFFFB960);
  static const Color primaryContainer = Color(0xFFC8862A);
  static const Color tertiary = Color(0xFFFFB3B4);
  static const Color amberGold = Color(0xFFD9A54D);
  static const Color ivoryWarm = Color(0xFFF7EDD9);
  
  // Status & Feedback
  static const Color error = Color(0xFFFFB4AB);
  static const Color warning = Color(0xFFBA7517);
  static const Color silverGray = Color(0xFFCCCCD1);

  // Content Colors
  static const Color onSurface = Color(0xFFE9E1DC);
  static const Color onSurfaceVariant = Color(0xFFD6C3B1);
  static const Color onPrimary = Color(0xFF472A00);

  // Glassmorphic Helpers
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
}
