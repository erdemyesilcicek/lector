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
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.background,
      onSecondary: AppColors.background,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.background,
    ),
    textTheme: TextTheme(/* ... AYNI ... */),
    appBarTheme: AppBarTheme(/* ... AYNI ... */),
    cardTheme: CardThemeData(/* ... AYNI ... */),
    elevatedButtonTheme: ElevatedButtonThemeData(/* ... AYNI ... */),
    outlinedButtonTheme: OutlinedButtonThemeData(/* ... AYNI ... */),
    textButtonTheme: TextButtonThemeData(/* ... AYNI ... */),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(/* ... AYNI ... */),
    dividerTheme: const DividerThemeData(/* ... AYNI ... */),
    inputDecorationTheme: InputDecorationTheme(/* ... AYNI ... */),
    // ... (Diğer stilleri önceki tam koddan kopyala)
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE0E0E0),
      secondary: AppColors.accent,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
      onPrimary: Color(0xFF121212),
      onSecondary: Color(0xFF121212),
      onBackground: Color(0xFFE0E0E0),
      onSurface: Color(0xFFE0E0E0),
      onError: Color(0xFF121212),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      displayMedium: AppTextStyles.headline2.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      displaySmall: AppTextStyles.headline3.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: const Color(0xFFBDBDBD),
      ),
      labelLarge: AppTextStyles.button.copyWith(color: const Color(0xFF121212)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: AppTextStyles.headline2.copyWith(
        color: const Color(0xFFE0E0E0),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF121212),
        textStyle: AppTextStyles.button.copyWith(
          color: const Color(0xFF121212),
        ),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFBDBDBD)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: AppColors.accent,
      unselectedItemColor: const Color(0xFFBDBDBD),
      type: BottomNavigationBarType.fixed,
      elevation: 4,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x44BDBDBD),
      thickness: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFFBDBDBD),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.0),
      ),
    ),
  );
}
