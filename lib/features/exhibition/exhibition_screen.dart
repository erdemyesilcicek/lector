// lib/features/exhibition/exhibition_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class ExhibitionScreen extends StatefulWidget {
  const ExhibitionScreen({super.key});

  @override
  State<ExhibitionScreen> createState() => _ExhibitionScreenState();
}

class _ExhibitionScreenState extends State<ExhibitionScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Exhibition'),
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ExhibitionBook>>(
        stream: _databaseService.getExhibitionStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center( // Geliştirilmiş Boş Ekran
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shelves, size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text('Your Exhibition is Empty', style: AppTextStyles.headline3, textAlign: TextAlign.center),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Mark books as read to build your gallery!',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final exhibitionList = snapshot.data!;

          // --- 3 SÜTUNLU GRIDVIEW ---
          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
              // YENİ EN/BOY ORANI: Başlık ve yazar için biraz daha yükseklik
              childAspectRatio: 0.55,
            ),
            itemCount: exhibitionList.length,
            itemBuilder: (context, index) {
              final exBook = exhibitionList[index];
              // --- YENİ KART TASARIMI KULLANILIYOR ---
              return _buildExhibitionCard(exBook);
            },
          );
        },
      ),
    );
  }

  // --- YENİ ÖZEL KART TASARIMI (Başlık ve Yazar ile) ---
  Widget _buildExhibitionCard(ExhibitionBook exBook) {
    final bool hasRealCover = !exBook.coverUrl.contains('i.imgur.com/J5LVHEL.png');

    final bookForDetail = Book(
      id: exBook.id, title: exBook.title, author: exBook.author,
      coverUrl: exBook.coverUrl, summary: exBook.summary, genres: exBook.genres,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailScreen(book: bookForDetail)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kapak Alanı
          Expanded(
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: hasRealCover
                  ? Image.network(
                      exBook.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return GeneratedCover(title: exBook.title, author: exBook.author);
                      },
                    )
                  : GeneratedCover(title: exBook.title, author: exBook.author),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall / 2), // Daha az boşluk
          // Bilgi Alanı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0), // Kenarlardan hafif boşluk
            child: Text(
              exBook.title,
              maxLines: 1, // Tek satır
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              exBook.author,
              maxLines: 1, // Tek satır
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 10), // Daha küçük font
            ),
          ),
        ],
      ),
    );
  }
}