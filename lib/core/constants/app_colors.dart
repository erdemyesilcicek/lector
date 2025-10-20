// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

// Uygulama genelinde kullanılacak olan renk sabitleri.
class AppColors {
  // Bu sınıfın bir nesnesinin oluşturulmasını engelliyoruz.
  AppColors._(); 

  // Ana Renkler (Branding)
  static const Color primary = Color(0xFF4A2C2A); // Koyu Kahve (Ana butonlar, başlıklar)
  static const Color accent = Color(0xFFD4AF37); // Antik Altın/Amber (Yıldızlar, vurgular)

  // Nötr Renkler
  static const Color background = Color.fromARGB(255, 255, 251, 248); 
  static const Color surface = Color(0xFFFFFFFF); // Beyaz (Kartlar, paneller)
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFF333333); // Neredeyse Siyah (Ana metinler)
  static const Color textSecondary = Color(0xFF757575); // Gri (Alt metinler, ipuçları)

  // Yardımcı Renkler
  static const Color success = Color(0xFF4CAF50); // Yeşil (Başarı durumları)
  static const Color error = Color(0xFFD32F2F); // Kırmızı (Hata durumları)
}