// lib/widgets/book_card_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverUrl;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRealCover = !coverUrl.contains('i.imgur.com/J5LVHEL.png');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.4),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: hasRealCover
                    ? Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return GeneratedCover(title: title, author: author);
                        },
                      )
                    : GeneratedCover(title: title, author: author),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
