// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class AppTheme {
  AppTheme._();

  // YENİ AYDINLIK TEMA (Medium Tarzı)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    scaffoldBackgroundColor: AppColors.background, // Saf Beyaz

    // Renk Şeması (Aydınlık tema üzerine kurulu)
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary, // Neredeyse Siyah
      secondary: AppColors.accent, // Saf Siyah (Butonlar için)
      background: AppColors.background, // Beyaz
      surface: AppColors.surface, // Beyaz
      error: AppColors.error,
      onPrimary: AppColors.background, // Siyah üstündeki yazı (Beyaz)
      onSecondary: AppColors.background, // Siyah üstündeki yazı (Beyaz)
      onBackground: AppColors.textPrimary, // Beyaz üstündeki yazı (Siyah)
      onSurface: AppColors.textPrimary, // Beyaz üstündeki yazı (Siyah)
      onError: AppColors.background, // Kırmızı üstündeki yazı (Beyaz)
    ),

    // Tipografi
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.button, // Butonlar için
    ),

    // AppBar Teması (Beyaz, alt çizgisiz)
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primary, // Geri butonu rengi
      elevation: 0, // Alt çizgiyi kaldır
      titleTextStyle: AppTextStyles.headline2,
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),

    // Kart Teması (Gölgesiz veya çok hafif)
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1, // Çok hafif gölge veya 0
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
         // İnce kenarlık ekleyebiliriz (opsiyonel)
        // side: BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),

    // Buton Temaları (Siyah butonlar)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent, // Saf Siyah
        foregroundColor: AppColors.background, // Beyaz Yazı
        textStyle: AppTextStyles.button,
        elevation: 1, // Hafif gölge
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
     outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary, // Siyah Yazı/İkon
        side: const BorderSide(color: AppColors.primary, width: 1.5), // Siyah kenarlık
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      )
     ),
     textButtonTheme: TextButtonThemeData(
       style: TextButton.styleFrom(
         foregroundColor: AppColors.textSecondary, // Gri yazı
       )
     ),

    // Alt Navigasyon Barı Teması
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface, // Beyaz
      selectedItemColor: AppColors.primary, // Seçili: Siyah
      unselectedItemColor: AppColors.textSecondary, // Seçili Değil: Gri
      type: BottomNavigationBarType.fixed,
      elevation: 4, // Hafif gölge
    ),

    // Divider Teması
    dividerTheme: const DividerThemeData(
      color: AppColors.border, // Açık Gri
      thickness: 0.5,
    ),

    // Input Alanları Teması
     inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100, // Çok açık gri dolgu
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none, // Kenarlık yok
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.0), // Odaklanınca siyah kenarlık
      ),
    ),
  );
}