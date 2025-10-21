// lib/core/constants/text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lector/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle headline1 = GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, // Güncellendi
  );

  static final TextStyle headline2 = GoogleFonts.lora(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, // Güncellendi
  );

  static final TextStyle headline3 = GoogleFonts.lora(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, // Güncellendi
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary, // Güncellendi
    height: 1.5, // Okunabilirlik için satır aralığı
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary, // Güncellendi
  );
  
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, // Güncellendi
  );

  // Buton metni artık accent (siyah) arka plan üzerinde beyaz olacak
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.background, // Beyaz
  );

  // Linkler veya özel vurgular için ikincil renk stili
   static final TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, // Orta Gri
  );
}