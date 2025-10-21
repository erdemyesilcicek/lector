// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // YENİ AYDINLIK TEMA (Medium Tarzı)
  static const Color primary = Color(0xFF1A1A1A); // Ana Renk (Metinler, Vurgulu İkonlar - Neredeyse Siyah)
  static const Color accent = Color(0xFF000000); // Vurgu Rengi (Butonlar için saf siyah deneyelim)
  // Alternatif Vurgu: Eğer siyah buton çok sert durursa diye eski altın rengini yorumda tutalım.
  // static const Color accent = Color(0xFFD4AF37); 

  static const Color background = Color(0xFFFFFFFF); // Arka Plan (Saf Beyaz)
  static const Color surface = Color(0xFFFFFFFF);   // Kart Arka Planı (Saf Beyaz)
  
  static const Color textPrimary = Color(0xFF1A1A1A); // Ana Metinler (Neredeyse Siyah)
  static const Color textSecondary = Color(0xFF666666); // İkincil Metinler (Orta Gri)

  static const Color border = Color(0xFFE0E0E0);   // Ayırıcılar, Kenarlıklar (Çok Açık Gri)

  static const Color success = Color(0xFF388E3C); // Yeşil (Aynı kalabilir)
  static const Color error = Color(0xFFC62828);   // Kırmızı (Aynı kalabilir)
}