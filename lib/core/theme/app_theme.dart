import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryBlue = Color(0xFF1A365D); // Deep blue
  static const Color secondaryBeige = Color(0xFFF2E8D9); // Warm beige
  static const Color accentOlive = Color(0xFF606C38); // Olive accent
  static const Color textDark = Color(0xFF2A2A2A);
  static const Color textMedium = Color(0xFF5C5C5C);
  static const Color textLight = Color(0xFF8A8A8A);
  static const Color background = Color(0xFFFAF9F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB71C1C);
  static const Color success = Color(0xFF43A047);

  // Typography
  static const String _serifFontFamily = 'Libre Baskerville';
  static const String _sansFontFamily = 'Montserrat';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: white,
        secondary: secondaryBeige,
        onSecondary: textDark,
        tertiary: accentOlive,
        onTertiary: white,
        error: error,
        onError: white,
        surface: white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
      textTheme: TextTheme(
        // Serif headings
        headlineLarge: const TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: const TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineSmall: const TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        // Sans-serif body
        bodyLarge: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          color: textMedium,
        ),
        bodySmall: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          color: textLight,
        ),
        labelLarge: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: primaryBlue,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textMedium,
        ),
        hintStyle: const TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textLight,
        ),
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shadowColor: primaryBlue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: secondaryBeige,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
