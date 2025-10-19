// lib/core/constants/text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lector/core/constants/app_colors.dart';

// Uygulama genelinde kullanılacak olan metin stilleri.
class AppTextStyles {
  AppTextStyles._();

  // Başlıklar için: Lora (Serifli, klasik ve zarif)
  // Gövde metinleri için: Inter (Sans-serif, modern ve çok okunaklı)

  static final TextStyle headline1 = GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle headline2 = GoogleFonts.lora(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle headline3 = GoogleFonts.lora(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.surface, // Genellikle butonların üstündeki yazı beyaz olur
  );
}