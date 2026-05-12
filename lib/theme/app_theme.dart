import 'package:flutter/material.dart';

class AppColors {
  // Primary (Улаан өнгөний хувилбарууд)
  static const primary = Color(0xFFD32F2F); // Үндсэн улаан
  static const primaryLight = Color(0xFFEF5350); // Тод цайвар улаан
  static const primaryDark = Color(0xFFB71C1C); // Гүн улаан

  // Secondary / Accent
  static const accent = Color(0xFFFFB800); // Алтан шар
  static const accentLight = Color(0xFFFFD60A);

  // Status
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Neutral
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFFFF0F0); // Улаан туяатай цайвар дэвсгэр
  static const border = Color(0xFFE2E8F0);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
  static const textWhite = Color(0xFFFFFFFF);

  // Loan type colors
  static const personalLoan = Color(0xFFD32F2F);
  static const mortgageLoan = Color(0xFF7C3AED);
  static const autoLoan = Color(0xFF059669);
  static const businessLoan = Color(0xFFD97706);
  static const educationLoan = Color(0xFF2563EB);
  static const emergencyLoan = Color(0xFF0891B2);

  // Gradient (Улаан ууссан өнгө)
  static const gradientStart = Color(0xFFB71C1C);
  static const gradientEnd = Color(0xFFEF5350);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Gilroy',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Gilroy',
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      // CardTheme биш CardThemeData болгож зассан хэсэг
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const heading2 = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const heading3 = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const amount = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
}