import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام التصميم: ستايل ديني هادئ وعصري
/// ألوان مستوحاة من الزخرفة الإسلامية: أخضر زُمردي غامق + ذهبي + عاجي
class AppColors {
  AppColors._();

  // اللون الأساسي - أخضر إسلامي عميق (يرمز للسكينة)
  static const Color primaryDark = Color(0xFF0B3D2E);
  static const Color primary = Color(0xFF14532D);
  static const Color primaryLight = Color(0xFF1E7A4C);

  // اللون الذهبي - للتفاصيل والزخرفة
  static const Color gold = Color(0xFFC9A24B);
  static const Color goldLight = Color(0xFFE8D5A3);

  // خلفيات
  static const Color backgroundLight = Color(0xFFFBF8F2); // عاجي دافئ
  static const Color backgroundDark = Color(0xFF0D1512);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16211C);

  // نص المصحف
  static const Color quranTextLight = Color(0xFF1A1A1A);
  static const Color quranTextDark = Color(0xFFECE6D9);

  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.cairoTextTheme(),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.surfaceLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.primaryDark,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.gold,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.surfaceDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.primaryDark,
      ),
    );
  }

  /// خط عرض القرآن حسب الرواية المختارة
  static TextStyle quranTextStyle({
    required bool isDark,
    required double fontSize,
    required bool isWarsh,
  }) {
    return TextStyle(
      fontFamily: isWarsh ? 'WarshFont' : 'Uthmani',
      fontSize: fontSize,
      height: 2.1,
      color: isDark ? AppColors.quranTextDark : AppColors.quranTextLight,
    );
  }
}
