// lib/features/explore/book_detail_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  late Stream<bool> _isInReadingListStream;
  late Stream<ExhibitionBook?> _exhibitionBookStream;

  @override
  void initState() {
    super.initState();
    _isInReadingListStream = _databaseService.isBookInReadingList(widget.book.id);
    _exhibitionBookStream = _databaseService.getExhibitionBookStream(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: ''),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(book.coverUrl), fit: BoxFit.cover),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 25, offset: Offset(0, 10))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      child: Image.network(book.coverUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'by ${book.author}',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  StreamBuilder<ExhibitionBook?>(
                    stream: _exhibitionBookStream,
                    builder: (context, snapshot) {
                      final exhibitionBook = snapshot.data;
                      if (exhibitionBook != null) {
                        return _buildExhibitionDetails(exhibitionBook);
                      }
                      return StreamBuilder<bool>(
                        stream: _isInReadingListStream,
                        builder: (context, snapshot) {
                          final isInReadingList = snapshot.data ?? false;
                          return _buildActionButtons(book, isInReadingList);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  const Divider(color: AppColors.textSecondary),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('About this book', style: AppTextStyles.headline3.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    book.summary,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Book book, bool isInReadingList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (context) => const RatingModal(),
                isScrollControlled: true,
              );
              if (result != null && mounted) {
                final int rating = result['rating'];
                final String notes = result['notes'];
                await _databaseService.addBookToExhibition(book, rating, notes);
                if (isInReadingList) {
                  await _databaseService.deleteFromReadingList(book.id);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved to your Exhibition!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Text('Mark as Read', style: AppTextStyles.button.copyWith(fontSize: 14)),
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (isInReadingList) {
                _databaseService.deleteFromReadingList(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from your Reading List!')),
                );
              } else {
                _databaseService.addBookToReadingList(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to your Reading List!')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Text(isInReadingList ? 'Remove' : 'Add to List', style: AppTextStyles.button.copyWith(color: AppColors.accent, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // --- "MANYAK" HALE GETİRİLMİŞ YENİ METOT ---
  Widget _buildExhibitionDetails(ExhibitionBook exhibitionBook) {
    // "Düzenle" butonuna tıklandığında çalışacak fonksiyon
    void openEditModal() async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (context) => RatingModal(
          initialRating: exhibitionBook.rating,
          initialNotes: exhibitionBook.notes,
        ),
        isScrollControlled: true,
      );
      if (result != null && mounted) {
        final int newRating = result['rating'];
        final String newNotes = result['notes'];
        await _databaseService.updateExhibitionBook(
            exhibitionBook.id, newRating, newNotes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your rating has been updated!')),
        );
      }
    }
    
    return Column(
      children: [
        // RATING BÖLÜMÜ
        Material(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: InkWell(
            onTap: openEditModal, // Düzenleme modal'ını aç
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text('Your Rating', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < exhibitionBook.rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.accent,
                          size: 24,
                        );
                      }),
                      const SizedBox(width: AppConstants.paddingSmall),
                      const Icon(Icons.edit, color: AppColors.textSecondary, size: 18),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        // NOT BÖLÜMÜ (Eğer not varsa gösterilir)
        if (exhibitionBook.notes.isNotEmpty) ...[
          const SizedBox(height: AppConstants.paddingMedium),
          Material(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            child: InkWell(
              onTap: openEditModal,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        exhibitionBook.notes,
                        style: AppTextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
        const SizedBox(height: AppConstants.paddingLarge),
        // REMOVE BUTONU (Daha az dikkat çekici)
        TextButton(
          onPressed: () async {
            await _databaseService.deleteFromExhibition(exhibitionBook.id);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${exhibitionBook.title} removed from Exhibition.')),
              );
            }
          },
          child: Text(
            'Remove from Exhibition',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}