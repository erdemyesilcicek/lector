// lib/widgets/explore_big_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class ExploreBigCard extends StatelessWidget {
  final Book book;
  final bool isInReadingList;
  final VoidCallback onMarkAsRead;
  final VoidCallback onToggleReadingList;

  const ExploreBigCard({
    super.key,
    required this.book,
    required this.isInReadingList,
    required this.onMarkAsRead,
    required this.onToggleReadingList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final bool hasRealCover = !book.coverUrl.contains('i.imgur.com/J5LVHEL.png');

    Widget coverWidget = hasRealCover
        ? Image.network(
            book.coverUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return ClipRRect(
                 borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                 child: Container(color: theme.colorScheme.surfaceVariant)
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return GeneratedCover(title: book.title, author: book.author);
            },
          )
        : GeneratedCover(title: book.title, author: book.author);

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // --- ARKA PLAN: Daha Az Bulanık Kapak ---
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              child: hasRealCover
              ? ImageFiltered(
                  // BLUR DEĞERLERİ AZALTILDI (Örn: 5.0)
                  imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                     decoration: BoxDecoration(
                       image: DecorationImage(image: NetworkImage(book.coverUrl), fit: BoxFit.cover),
                     ),
                     // Karartma efekti biraz azaltılabilir
                     child: Container(color: Colors.black.withOpacity(0.35)),
                  ),
                )
              : Container(color: theme.colorScheme.surfaceVariant),
            ),
          ),

          // --- ÖN PLAN: İçerik ---
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium), // Padding biraz azaltıldı
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3), // Üstteki boşluk oranı ayarlandı
                // Başlık (Küçültüldü)
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  // titleLarge veya titleMedium daha uygun olabilir
                  style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [const Shadow(blurRadius: 3, color: Colors.black87)]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.paddingSmall / 2),
                // Yazar (Küçültüldü)
                Text(
                  'by ${book.author}',
                  textAlign: TextAlign.center,
                  // bodyMedium veya bodySmall daha uygun
                  style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85), // Biraz daha görünür
                      fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(flex: 4), // Butonları aşağı itmek için boşluk oranı ayarlandı
                // Butonlar (Yazıları Değişti)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMarkAsRead,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        // YAZI DEĞİŞTİ
                        label: const Text('Read'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                          ),
                          textStyle: textTheme.labelMedium, // labelMedium daha küçük
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onToggleReadingList,
                        icon: Icon(
                          isInReadingList ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                          size: 18
                        ),
                        // YAZI DEĞİŞTİ
                        label: Text(isInReadingList ? 'Remove' : 'Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                            side: BorderSide(color: colorScheme.secondary.withOpacity(0.5))
                          ),
                          elevation: 1,
                           textStyle: textTheme.labelMedium, // labelMedium daha küçük
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}