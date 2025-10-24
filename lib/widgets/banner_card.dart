// lib/widgets/banner_card.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';

class BannerCard extends StatelessWidget {
  final String title;
  final String description;
  final String? assetImagePath; // Yerel görsel yolu (ÖNCELİKLİ)
  final String? imageUrl; // Network görsel URL'si (Asset yoksa kullanılır)
  final VoidCallback? onTap;
  final double? height; // Kartın yüksekliği (Opsiyonel, verilmezse içeriğe göre ayarlanır)
  final Color? backgroundColor;

  const BannerCard({
    super.key,
    required this.title,
    required this.description,
    this.assetImagePath,
    this.imageUrl,
    this.onTap,
    this.height,
    this.backgroundColor,
  }) : assert(assetImagePath != null || imageUrl != null,
            'BannerCard requires either assetImagePath or imageUrl.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- Görsel Widget'ını Belirleme ---
    Widget imageWidget;
    bool imageAvailable = false; // Görselin geçerli olup olmadığını takip etmek için

    // 1. Önce Asset Görselini Dene
    if (assetImagePath != null && assetImagePath!.isNotEmpty) {
      imageAvailable = true;
      imageWidget = Image.asset(
        assetImagePath!,
        key: ValueKey('asset_$assetImagePath'),
        // ORTALAMA İÇİN BoxFit.contain KULLANIYORUZ
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Asset Error for '$assetImagePath': $error");
          imageAvailable = false; // Hata durumunda görsel yok say
          return _buildPlaceholderImage(theme); // Yer tutucu göster
        },
      );
    }
    // 2. Asset Yoksa Network Görselini Dene
    else if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http')) {
      imageAvailable = true;
      imageWidget = Image.network(
        imageUrl!,
        key: ValueKey('network_$imageUrl'),
        // ORTALAMA İÇİN BoxFit.contain KULLANIYORUZ
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Yüklenirken de yer tutucu gösterelim
          return _buildPlaceholderImage(theme, isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Network Error for '$imageUrl': $error");
          imageAvailable = false; // Hata durumunda görsel yok say
          return _buildPlaceholderImage(theme); // Yer tutucu göster
        },
      );
    }
    // 3. İkisi de Geçerli Değilse Yer Tutucu Göster
    else {
      imageAvailable = false;
      imageWidget = _buildPlaceholderImage(theme);
    }

    // --- Kartın Ana Yapısı ---
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        color: backgroundColor ?? theme.cardTheme.color ?? theme.cardColor,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        elevation: theme.cardTheme.elevation ?? 1,
        shape: theme.cardTheme.shape ?? RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
         ),
        child: SizedBox(
          height: height ?? 120.0, // Varsayılan yüksekliği 120.0 olarak ayarladım
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Dikeyde tüm alanı kapla
              children: [
                // --- SOL TARAF: METİN (%60) ---
                Expanded(
                  flex: 3, // Toplam 5 flex'in 3'ü (%60)
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, // Metin bloğunu dikeyde ortala
                      children: [
                        Text(
                          title,
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall / 2),
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // --- SAĞ TARAF: GÖRSEL (%40) ---
                Expanded(
                  flex: 2, // Toplam 5 flex'in 2'si (%40)
                  // Görseli kendi alanının ortasına yerleştirmek için Container + Center
                  child: Container(
                    // Görsel yoksa veya hata varsa arka plan rengi belli olsun
                    color: imageAvailable ? Colors.transparent : theme.colorScheme.surfaceVariant,
                    // Görseli ortalamak için Padding ekleyebiliriz (opsiyonel)
                    padding: const EdgeInsets.all(AppConstants.paddingSmall / 2),
                    child: Center(
                      // Görselin köşelerini kartın köşelerine uyduralım
                      child: ClipRRect(
                         borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall), // Hafif yuvarlak köşe
                         child: imageWidget, // Yukarıda belirlediğimiz imageWidget
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Yer tutucu görsel veya yükleme animasyonu için yardımcı metot
  Widget _buildPlaceholderImage(ThemeData theme, {bool isLoading = false}) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0))
          : Icon(Icons.image_not_supported_outlined, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
    );
  }
}