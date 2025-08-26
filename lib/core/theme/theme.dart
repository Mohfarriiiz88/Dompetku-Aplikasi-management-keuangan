import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna & styling terpusat (Poppins)
class AppColors {
  static const gradientStart = Color(0xFF0E0B28); // biru gelap
  static const gradientEnd   = Color(0xFF282180); // biru
  static const yellow        = Color(0xFFFFCE39);
  static const purple        = Color(0xFF292281);
  static const red           = Color(0xFFF34C3A);
  static const green         = Color(0xFF00B232);
  static const greySurface   = Color(0xFFF8F5F0);
  static const white         = Color(0xFFFFFFFF);
  static const textDark      = Color(0xFF0E0B28);
}

class AppGradients {
  static const brand = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}

class AppRadius {
  static const sheet = BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(28),
  );
  static const field = BorderRadius.all(Radius.circular(10));
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.purple,
        secondary: AppColors.yellow,
        background: AppColors.white,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppRadius.field),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppRadius.field),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: AppRadius.field),
        hintStyle: TextStyle(color: Colors.black54),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
    );
  }
}
