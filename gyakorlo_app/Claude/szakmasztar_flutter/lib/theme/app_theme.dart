import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color purple = Color(0xFF5B5BF6);
  static const Color purpleLight = Color(0xFF9898FF);
  static const Color purpleDark = Color(0xFF8B5CF6);
  static const Color purpleSoft = Color(0xFFADADFF);

  // Grades
  static const Color green = Color(0xFF34D399);
  static const Color greenLight = Color(0xFF6EE7B7);
  static const Color blue = Color(0xFF60A5FA);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color yellowLight = Color(0xFFFDE68A);
  static const Color red = Color(0xFFF87171);
  static const Color redLight = Color(0xFFFCA5A5);
  static const Color orange = Color(0xFFF97316);

  // Dark theme
  static const Color darkBg = Color(0xFF0D0D14);
  static const Color darkSurface = Color(0xFF13131F);

  // Light theme
  static const Color lightBg = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class AppTheme {
  static bool isDark(BuildContext context, String themeMode) {
    switch (themeMode) {
      case 'dark':
        return true;
      case 'light':
        return false;
      default:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  static Color bg(bool dark) => dark ? AppColors.darkBg : AppColors.lightBg;
  static Color primaryText(bool dark) => dark ? Colors.white : const Color(0xFF1C1C1E);
  static Color secondaryText(bool dark) => dark
      ? Colors.white.withOpacity(0.45)
      : const Color(0xFF1C1C1E).withOpacity(0.55);
  static Color surfaceBg(bool dark) => dark
      ? Colors.white.withOpacity(0.06)
      : const Color(0xFF1C1C1E).withOpacity(0.06);
  static Color surfaceBorder(bool dark) => dark
      ? Colors.white.withOpacity(0.1)
      : const Color(0xFF1C1C1E).withOpacity(0.1);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [AppColors.purple, AppColors.purpleDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
