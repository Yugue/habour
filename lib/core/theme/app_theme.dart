import 'package:flutter/material.dart';

class AppTheme {
  // Color palette - Elegant and grounded
  static const Color primaryDeepBlue =
      Color(0xFF1E3A5F); // Deep sophisticated blue
  static const Color secondaryWarmBeige =
      Color(0xFFF5E6D3); // Warm, inviting beige
  static const Color accentOlive = Color(0xFF6B7C47); // Muted olive accent

  // Supporting colors
  static const Color backgroundLight = Color(0xFFFAF8F5); // Slightly warm white
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardBackground =
      Color(0xFFFFFDFA); // Very subtle warm white

  // Text colors
  static const Color textPrimary =
      Color(0xFF2C2825); // Almost black, warm undertone
  static const Color textSecondary = Color(0xFF5C5651); // Medium gray-brown
  static const Color textTertiary = Color(0xFF8B8680); // Light gray-brown
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Functional colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4A7C59); // Olive-tinted green
  static const Color warning = Color(0xFFE8A634);
  static const Color dividerLight = Color(0xFFE8E2DB);

  // Border and shadow colors
  static const Color borderLight = Color(0xFFE2DDD7);
  static const Color shadowColor = Color(0x0A1E3A5F); // Very subtle blue shadow

  // Typography
  static const String _serifFontFamily = 'Libre Baskerville';
  static const String _sansFontFamily = 'Montserrat';

  // Border radius constants (Hinge-inspired)
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryDeepBlue,
        onPrimary: textOnPrimary,
        secondary: secondaryWarmBeige,
        onSecondary: textPrimary,
        tertiary: accentOlive,
        onTertiary: textOnPrimary,
        error: error,
        onError: textOnPrimary,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerHighest: cardBackground,
      ),
      scaffoldBackgroundColor: backgroundLight,

      // AppBar with elegant styling
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false, // More modern, left-aligned
        titleTextStyle: const TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),

      // Refined typography
      textTheme: TextTheme(
        // Display styles - for splash screens, etc.
        displayLarge: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -1.0,
          height: 1.3,
        ),

        // Headlines - Serif
        headlineLarge: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),

        // Title styles - Sans serif
        titleLarge: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.45,
        ),
        titleSmall: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.1,
          height: 1.5,
        ),

        // Body text - Sans serif
        bodyLarge: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.15,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.15,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
          letterSpacing: 0.2,
          height: 1.5,
        ),

        // Labels
        labelLarge: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.3,
        ),
      ),

      // Elegant button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeepBlue,
          foregroundColor: textOnPrimary,
          disabledBackgroundColor: borderLight,
          disabledForegroundColor: textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          minimumSize:
              const Size(0, 56), // Allow flexible width, but maintain height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDeepBlue,
          side: BorderSide(color: borderLight, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          minimumSize:
              const Size(0, 56), // Allow flexible width, but maintain height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDeepBlue,
          textStyle: const TextStyle(
            fontFamily: _sansFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // Input fields with Hinge-style borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primaryDeepBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: error, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          color: error,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card theme with elegant shadows
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: borderLight, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: dividerLight,
        thickness: 1,
        space: 32,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: secondaryWarmBeige,
        selectedColor: primaryDeepBlue,
        disabledColor: borderLight,
        labelStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryDeepBlue,
        unselectedItemColor: textTertiary,
        selectedIconTheme: IconThemeData(
          color: primaryDeepBlue,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: textTertiary,
          size: 28,
        ),
        selectedLabelStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _serifFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 16,
          color: textSecondary,
          height: 1.6,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 16,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
        dragHandleColor: borderLight,
        dragHandleSize: const Size(48, 4),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(
          fontFamily: _sansFontFamily,
          fontSize: 14,
          color: textOnPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Extension for easy access to theme colors
extension ThemeExtension on BuildContext {
  AppTheme get appTheme => AppTheme();

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get errorColor => Theme.of(this).colorScheme.error;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
