// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class AppTheme {
  AppTheme._();

  // Artık bir "darkTheme" oluşturuyoruz
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, // Temanın koyu olduğunu belirtiyoruz
    
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 2,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        borderSide: BorderSide.none,
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
  );
}