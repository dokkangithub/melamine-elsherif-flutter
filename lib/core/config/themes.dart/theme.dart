import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFB65B4F); // Deep Purple
  static const Color secondaryColor = Color(0x80C2665A); // Pink
  static const Color accentColor = Color(0xFFB65B4F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);

  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color errorColor = Color(0xFFF44336); // Red

  static const Color lightBackgroundColor = Color(0xFFF7F7F9);
  static const Color darkBackgroundColor = Color(0xFF121212);

  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1E1E1E);

  static const Color lightTextColor = Color(0xFF212121);
  static const Color darkTextColor = Color(0xFFF5F5F5);

  static const Color lightSecondaryTextColor = Color(0xFF757575);
  static const Color darkSecondaryTextColor = Color(0xFFBDBDBD);

  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color darkDividerColor = Color(0xFF424242);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    primaryColorDark: primaryColor.withValues(alpha: 0.8),
    primaryColorLight: primaryColor.withValues(alpha: 0.2),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: lightCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: white,
    cardColor: lightCardColor,
    dividerColor: lightDividerColor,
    fontFamily: 'Dokkan',

    // Apply custom Dokkan font
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: black,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        fontFamily: 'Dokkan',
      ),
      displayMedium: TextStyle(
        color: black,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        fontFamily: 'Dokkan',
      ),
      displaySmall: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        fontFamily: 'Dokkan',
      ),
      headlineMedium: TextStyle(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontFamily: 'Dokkan',
      ),
      headlineSmall: TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      titleLarge: TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      titleMedium: TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      titleSmall: TextStyle(
        color: black,
        fontSize: 12,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      bodyLarge: TextStyle(
        color: black,
        fontSize: 11,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      bodyMedium: TextStyle(
        color: black,
        fontSize: 10,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      bodySmall: TextStyle(
        color: black,
        fontSize: 9,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
      labelLarge: TextStyle(
        color: black,
        fontSize: 8,
        fontWeight: FontWeight.w300,
        fontFamily: 'Dokkan',
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          fontFamily: 'Dokkan',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          fontFamily: 'Dokkan',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          fontFamily: 'Dokkan',
        ),
      ),
    ),

    // Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: lightSecondaryTextColor, 
        fontSize: 16,
        fontFamily: 'Dokkan',
      ),
      hintStyle: const TextStyle(
        color: lightSecondaryTextColor, 
        fontSize: 16,
        fontFamily: 'Dokkan',
      ),
      errorStyle: const TextStyle(
        color: errorColor, 
        fontSize: 12,
        fontFamily: 'Dokkan',
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Dokkan',
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightSecondaryTextColor,
      selectedLabelStyle: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w500,
        fontFamily: 'Dokkan',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w500,
        fontFamily: 'Dokkan',
      ),
      elevation: 8,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withValues(alpha: 0.5);
        }
        return Colors.grey.withValues(alpha: 0.5);
      }),
    ),
  );
}

