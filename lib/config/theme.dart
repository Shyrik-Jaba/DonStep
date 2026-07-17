import 'package:flutter/material.dart';

class DonStepColors {
  static const lime = Color(0xFFC6E93C);
  static const black = Color(0xFF000000);
  static const darkGray = Color(0xFF1C1C1E);
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF2F2F7);
  static const mediumGray = Color(0xFF8E8E93);
  static const silverGray = Color(0xFFAEAEB2);
}

class DonStepTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DonStepColors.lime,
      scaffoldBackgroundColor: DonStepColors.black,
      colorScheme: const ColorScheme.dark(
        primary: DonStepColors.lime,
        secondary: DonStepColors.lime,
        surface: DonStepColors.darkGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DonStepColors.black,
        foregroundColor: DonStepColors.white,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: DonStepColors.darkGray,
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DonStepColors.darkGray,
        selectedItemColor: DonStepColors.lime,
        unselectedItemColor: DonStepColors.mediumGray,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DonStepColors.lime,
        foregroundColor: DonStepColors.black,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: DonStepColors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: DonStepColors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: DonStepColors.white),
        bodyMedium: TextStyle(color: DonStepColors.lightGray),
        bodySmall: TextStyle(color: DonStepColors.mediumGray),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DonStepColors.darkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DonStepColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DonStepColors.lime, width: 2),
        ),
        labelStyle: const TextStyle(color: DonStepColors.mediumGray),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DonStepColors.lime,
          foregroundColor: DonStepColors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
