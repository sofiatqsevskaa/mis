import 'package:flutter/material.dart';

class AppTheme {
  static const Color charcoal = Color.fromARGB(255, 0, 0, 0);
  static const Color lightGray = Color.fromARGB(255, 180, 180, 180);
  static const Color darkGray = Color.fromARGB(255, 74, 74, 74);
  static const Color burgundy = Color.fromARGB(255, 45, 5, 5);
  static const Color offWhite = Color.fromARGB(255, 245, 245, 245);
  static const Color mediumGray = Color.fromARGB(255, 220, 220, 220);
  static const Color accent = Color.fromARGB(255, 232, 232, 232);
  static const Color gray = Color.fromARGB(255, 171, 171, 171);
  static const Color error = Color.fromARGB(255, 200, 50, 50);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'AkzidenzGrotesk',
      primaryColor: burgundy,
      scaffoldBackgroundColor: offWhite,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,

      appBarTheme: const AppBarTheme(
        backgroundColor: charcoal,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'AkzidenzGrotesk',
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: white,
        unselectedLabelColor: mediumGray,
        indicator: const BoxDecoration(
          border: Border(bottom: BorderSide(color: white, width: 3)),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: burgundy,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: const BorderSide(color: charcoal, width: 2),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          side: const BorderSide(color: charcoal, width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: burgundy,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: charcoal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: charcoal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: burgundy, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: error, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: error, width: 3),
        ),
        filled: true,
        fillColor: white,
        labelStyle: TextStyle(color: charcoal, fontWeight: FontWeight.w700),
        hintStyle: TextStyle(color: darkGray),
      ),

      cardTheme: const CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: charcoal, width: 2),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: charcoal, width: 3),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      dividerTheme: const DividerThemeData(color: charcoal, thickness: 1),

      iconTheme: const IconThemeData(color: charcoal),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: charcoal,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          color: charcoal,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: charcoal,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: charcoal, fontSize: 16),
        bodyMedium: TextStyle(color: darkGray, fontSize: 14),
        labelLarge: TextStyle(
          color: burgundy,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: burgundy,
        onPrimary: white,
        secondary: charcoal,
        onSecondary: white,
        error: error,
        onError: white,
        surface: white,
        onSurface: charcoal,
      ),
    );
  }
}
