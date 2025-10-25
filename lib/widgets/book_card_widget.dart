// lib/widgets/book_card_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverUrl;
  final VoidCallback onTap;
  // YENİ PARAMETRE: Ödül rozeti gösterilsin mi?
  final bool showAwardBadge;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.onTap,
    this.showAwardBadge = false, // Varsayılan olarak gösterme
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı al
    final textTheme = theme.textTheme;
    final bool hasRealCover = !coverUrl.contains('i.imgur.com/J5LVHEL.png');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: 130, // Genişliği dışarıdan (SizedBox ile) alması daha iyi
        margin: const EdgeInsets.only(right: AppConstants.paddingMedium), // Sadece sağ boşluk kalsın
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KAPAK GÖRSELİ ALANI + ROZET ---
            Expanded(
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.4),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                // Stack kullanarak rozeti kapağın üzerine yerleştireceğiz
                child: Stack(
                  fit: StackFit.expand, // Stack'in Card boyutunda olmasını sağla
                  children: [
                    // Kapak Resmi (veya Generated Cover)
                    hasRealCover
                        ? Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: theme.colorScheme.secondary)));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return GeneratedCover(title: title, author: author);
                            },
                          )
                        : GeneratedCover(title: title, author: author),

                    // --- ÖDÜL ROZETİ (Eğer showAwardBadge true ise) ---
                    if (showAwardBadge)
                      Positioned(
                        top: AppConstants.paddingSmall / 2,
                        left: AppConstants.paddingSmall / 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            // Altın rengi veya tema secondary rengi
                            color: AppColors.star.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: Offset(1,1))
                            ]
                          ),
                          child: const Icon(
                            Icons.emoji_events_outlined, // Ödül ikonu
                            color: Colors.white, // Veya koyu tema için AppColors.background
                            size: 16,
                          ),
                        ),
                      ),
                    // --- ---
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall / 2),

            // --- KİTAP BİLGİLERİ ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                maxLines: 1, // Tek satır
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold), // bodySmall daha uygun
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                author,
                maxLines: 1, // Tek satır
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)), // Daha küçük ve soluk
              ),
            ),
          ],
        ),
      ),
    );
  }
}