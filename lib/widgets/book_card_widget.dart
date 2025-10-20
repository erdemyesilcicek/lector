// lib/widgets/book_card_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/widgets/generated_cover_widget.dart'; // Yeni widget'ımızı import ediyoruz

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
    // Kapak URL'sinin placeholder (yer tutucu) olup olmadığını kontrol et
    final bool hasRealCover = !coverUrl.contains('i.imgur.com/J5LVHEL.png');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap Kapağı Alanı
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                // ClipRRect, içindeki widget'ı dış container'ın yuvarlak köşelerine uymaya zorlar
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // AKILLI KONTROL BURADA
                  child: hasRealCover
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          // Resim yüklenirken veya hata oluşursa ne olacağı
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Eğer resim URL'si bozuksa yine de GeneratedCover'ı göster
                            return GeneratedCover(title: title, author: author);
                          },
                        )
                      : GeneratedCover(title: title, author: author),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Kitap Başlığı
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // Yazar
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}