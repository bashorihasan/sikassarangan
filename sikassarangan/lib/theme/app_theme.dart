import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBrown = Color(0xFF4A2C1D);
  static const Color deepBrown = Color(0xFF5D3A1A);
  static const Color gold = Color(0xFFC9A34E);
  static const Color goldSoft = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFF5EFE6);
  static const Color surface = Color(0xFFFFFBF5);
  static const Color brickRed = Color(0xFF8B4A3A);
  static const Color success = Color(0xFF4E7D5F);
  static const Color pending = Color(0xFF8A8A8A);
  static const Color reimburse = Color(0xFFB58F27);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBrown,
        secondary: AppColors.gold,
        tertiary: AppColors.deepBrown,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: AppColors.primaryBrown,
        onSurface: const Color(0xFF2B1B11),
        error: Colors.red.shade700,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2B1B11),
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2B1B11),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: Color(0xFF8C7A6A)),
        labelStyle: const TextStyle(color: Color(0xFF6A5244)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE4D7C9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrown,
          side: const BorderSide(color: AppColors.primaryBrown),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.goldSoft,
        foregroundColor: AppColors.primaryBrown,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1E5D5),
        selectedColor: AppColors.gold.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Color(0xFF2B1B11)),
        side: const BorderSide(color: Color(0xFFE7D3BC)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerColor: const Color(0xFFE5D6C6),
    );
  }
}
