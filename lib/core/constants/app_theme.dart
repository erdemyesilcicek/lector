// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Renk Şeması
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // Tipografi
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),

    // AppBar Teması
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: AppTextStyles.headline2.copyWith(color: AppColors.primary),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),

    // Buton Temaları
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
    
    // Diğer component'lerin temalarını da buraya ekleyebiliriz.
  );
}