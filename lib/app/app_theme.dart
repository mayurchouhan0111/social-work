import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color elevatedSurface = Color(0xFF242424);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB3B3B3);
  static const Color disabledText = Color(0xFF666666);
  static const Color accent1 = Color(0xFF4CC9F0);
  static const Color accent2 = Color(0xFFFF8800);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF4C4C);
  static const Color divider = Color(0xFF2C2C2C);
  static final Color hoverEffect = Color.fromRGBO(76, 201, 240, 0.15);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent2,
        secondary: accent1,
        background: background,
        surface: surface,
        error: error,
        onPrimary: primaryText,
        onSecondary: Color(0xFF0D0D0D),
        onBackground: primaryText,
        onSurface: primaryText,
        onError: primaryText,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.archivo(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        displayMedium: GoogleFonts.archivo(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        displaySmall: GoogleFonts.archivo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        bodyLarge: GoogleFonts.archivo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        bodyMedium: GoogleFonts.archivo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
        labelLarge: GoogleFonts.archivo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        titleTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        iconTheme: IconThemeData(
          color: accent1,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent2,
        foregroundColor: primaryText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent2,
          foregroundColor: primaryText,
          textStyle: const TextStyle(
            fontFamily: 'Archivo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: accent1,
          foregroundColor: const Color(0xFF0D0D0D),
          textStyle: const TextStyle(
            fontFamily: 'Archivo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}