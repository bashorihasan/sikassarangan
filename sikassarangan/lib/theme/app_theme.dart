import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBrown = Color(0xFF4A2C1D);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color backgroundCream = Color(0xFFF5EFE6);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderSoft = Color(0xFFE6D9C3);
  static const Color textOnBrown = Color(0xFFF5EFE6);
  static const Color textSecondaryBrown = Color(0xFF8A6D3B);
  static const Color textCardTitle = Color(0xFF3A2515);
  static const Color cashOutRed = Color(0xFFA34A2E);
  static const Color cashInGreen = Color(0xFF3B8256);
  static const Color reimburseBackground = Color(0xFFF5E6BE);
  static const Color reimburseText = Color(0xFF7A5A0A);
  static const Color lunasBackground = Color(0xFFDCEBD9);
  static const Color lunasText = Color(0xFF2F6B45);
  static const Color pendingBackground = Color(0xFFE6D9C3);
  static const Color pendingText = Color(0xFF6B5A3D);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final textTheme = GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w400,
        ),
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.displayMedium?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w400,
        ),
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.displaySmall?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w400,
        ),
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w400,
        ),
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.textCardTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: baseTextTheme.labelSmall?.copyWith(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    final colorScheme = const ColorScheme.light().copyWith(
      primary: AppColors.primaryBrown,
      onPrimary: AppColors.textOnBrown,
      secondary: AppColors.accentGold,
      onSecondary: AppColors.primaryBrown,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textCardTitle,
      error: AppColors.cashOutRed,
      outline: AppColors.borderSoft,
      tertiary: AppColors.cashInGreen,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundCream,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.textOnBrown,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSoft, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryBrown,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cashOutRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cashOutRed, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryBrown,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrown,
          side: const BorderSide(color: AppColors.accentGold, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBrown,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryBrown,
        shape: CircleBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentGold,
        circularTrackColor: AppColors.borderSoft,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryBrown,
        contentTextStyle: TextStyle(
          color: AppColors.textOnBrown,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: AppColors.accentGold,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 0.5,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textCardTitle,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondaryBrown,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
