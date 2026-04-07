import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LinguaVerse Design Tokens
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand primaries
  static const primary      = Color(0xFF1A56DB); // deep blue
  static const primaryLight = Color(0xFF3B82F6); // medium blue
  static const primaryDark  = Color(0xFF0F2A5C); // navy

  // Accent
  static const teal         = Color(0xFF0E9F6E); // success / correct
  static const tealLight    = Color(0xFF34D399); // light teal
  static const orange       = Color(0xFFD97706); // warning / streak
  static const orangeLight  = Color(0xFFFBBF24); // bright amber
  static const purple       = Color(0xFF7C3AED); // achievements
  static const purpleLight  = Color(0xFFA78BFA); // light purple
  static const red          = Color(0xFFDC2626); // error / wrong
  static const redLight     = Color(0xFFFCA5A5); // light red
  static const pink         = Color(0xFFEC4899); // highlight

  // Neutrals
  static const dark         = Color(0xFF0F172A); // near black
  static const body         = Color(0xFF1E293B); // body text
  static const sub          = Color(0xFF475569); // secondary text
  static const muted        = Color(0xFF94A3B8); // muted text
  static const border       = Color(0xFFCBD5E1); // borders
  static const bg           = Color(0xFFF8FAFC); // screen bg
  static const cardBg       = Color(0xFFFFFFFF); // card bg
  static const surface      = Color(0xFFF1F5F9); // surface

  // Tinted backgrounds
  static const lBlue        = Color(0xFFEBF5FF);
  static const lTeal        = Color(0xFFE6F9F0);
  static const lPurple      = Color(0xFFF3EEFF);
  static const lOrange      = Color(0xFFFFF8E6);
  static const lRed         = Color(0xFFFFF0F0);
  static const lPink        = Color(0xFFFDF2F8);

  // Gradients
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A56DB), Color(0xFF7C3AED)],
  );

  static const gradientTeal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E9F6E), Color(0xFF3B82F6)],
  );

  static const gradientWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFEC4899)],
  );

  static const gradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );
}

class AppSpacing {
  AppSpacing._();
  static const xs  =  4.0;
  static const sm  =  8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  AppRadius._();
  static const xs   = Radius.circular(4);
  static const sm   = Radius.circular(8);
  static const md   = Radius.circular(12);
  static const lg   = Radius.circular(16);
  static const xl   = Radius.circular(24);
  static const xxl  = Radius.circular(32);
  static const full = Radius.circular(999);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Nunito', // set in pubspec — closest free font to Duolingo
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.dark, letterSpacing: -0.3),
      displaySmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark),
      headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.body),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.body),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.sub),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.body),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.dark,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
