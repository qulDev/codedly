import 'package:flutter/material.dart';

/// Duolingo-inspired color palette for Codedly dark theme
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF58CC02); // Duolingo green
  static const Color primaryDark = Color(0xFF46A302);
  static const Color primaryLight = Color(0xFF6FE019);

  // Secondary colors
  static const Color secondary = Color(0xFF1CB0F6); // Blue
  static const Color secondaryDark = Color(0xFF1899D6);
  static const Color secondaryLight = Color(0xFF33C0FF);

  // Background colors
  static const Color background = Color(0xFF131313); // Deep dark
  static const Color surface = Color(0xFF1F1F1F); // Card background
  static const Color surfaceVariant = Color(0xFF2A2A2A); // Elevated surface

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);
  static const Color textDisabled = Color(0xFF6E6E6E);

  // Status colors
  static const Color success = Color(0xFF58CC02);
  static const Color error = Color(0xFFFF4B4B);
  static const Color warning = Color(0xFFFFC800);
  static const Color info = Color(0xFF1CB0F6);

  // XP and gamification colors
  static const Color xpGold = Color(0xFFFFC800);
  static const Color levelBadge = Color(0xFF7C4DFF);
  static const Color streakFire = Color(0xFFFF9500);

  // Code editor colors
  static const Color codeBackground = Color(0xFF1E1E1E);
  static const Color codeLine = Color(0xFF2D2D2D);
  static const Color codeSelection = Color(0xFF264F78);

  // Accent colors for variety
  static const Color accent1 = Color(0xFFFF4B4B); // Red
  static const Color accent2 = Color(0xFFFFC800); // Yellow
  static const Color accent3 = Color(0xFF7C4DFF); // Purple
  static const Color accent4 = Color(0xFF1CB0F6); // Blue
}
