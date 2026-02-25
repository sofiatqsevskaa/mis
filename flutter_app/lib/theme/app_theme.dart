import 'package:flutter/material.dart';

class AppTheme {
  static const Color warmBrown = Color(0xFF8B5A2B);
  static const Color lightBrown = Color(0xFFB78C5A);
  static const Color darkBrown = Color(0xFF5D3A1A);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color gold = Color(0xFFD4AF37);
  static const Color accent = Color(0xFFD4AF37);
  static const Color lightGray = Color.fromARGB(255, 105, 105, 105);
  static const Color error = Color.fromARGB(255, 255, 0, 0);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: warmBrown,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: warmBrown,
        foregroundColor: cream,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: darkBrown,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: darkBrown,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: warmBrown),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        labelStyle: const TextStyle(color: warmBrown),
        hintStyle: const TextStyle(color: lightBrown),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: lightBrown),
        titleLarge: TextStyle(color: darkBrown),
      ),
    );
  }
}
