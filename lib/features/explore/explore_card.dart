// lib/widgets/explore_card.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart'; // Sabitlerimizi kullanacağız

class ExploreCard extends StatelessWidget {
  final String iconAssetPath; // assets/images/icon_adi.png gibi
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor; // Opsiyonel arka plan rengi

  const ExploreCard({
    super.key,
    required this.iconAssetPath,
    required this.text,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Telefon ekranında yatayda 3 tane sığması için yaklaşık genişliği hesaplayalım.
    // Ekran genişliği / 3 - (padding'ler / 2)
    // Bu widget'ı kullanan yerdeki GridView veya Row bu boyutu yönetecektir,
    // ancak biz de iç yapıyı bu genişliğe uygun tasarlayalım.
    // Şimdilik widget'a sabit genişlik vermeyelim, dış layout yönetsin.

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Kartın tamamı tıklanabilir olsun
      child: Card(
        // Tema'dan veya özel rengi al, yoksa surfaceVariant kullan
        color: backgroundColor ?? AppColors.surface,
        elevation: 1, // Daha minimalist bir görünüm için gölgeyi kaldıralım
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // Daha belirgin yuvarlak köşe
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // İçeriği dikeyde ortala
            crossAxisAlignment: CrossAxisAlignment.center, // İçeriği yatayda ortala
            children: [
              // İkon Alanı
              Expanded( // İkonun mevcut alanı doldurmasını sağla
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  child: Image.asset(
                    iconAssetPath,
                    // İkon rengini tema metin rengiyle uyumlu yapalım (opsiyonel)
                    // color: theme.colorScheme.onSurfaceVariant,
                    fit: BoxFit.contain, // Oranını koruyarak sığdır
                    errorBuilder: (context, error, stackTrace) {
                      print("!!! ExploreCard Asset Error for '$iconAssetPath': $error");
                      // Hata durumunda yer tutucu ikon
                      return Icon(
                        Icons.category_outlined, // Varsayılan kategori ikonu
                        size: 40, // Boyutu belirle
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      );
                    },
                  ),
                ),
              ),
              // Metin Alanı
              Text(
                text,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500, // Hafif kalın
                  color: theme.colorScheme.onSurfaceVariant, // Arka plana uygun renk
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // En fazla iki satır
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}