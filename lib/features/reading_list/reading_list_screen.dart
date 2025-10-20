// lib/features/reading_list/reading_list_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Reading List'),
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<Book>>(
        stream: _databaseService.getReadingListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark_border_rounded, size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text('Your Reading List is Empty', style: AppTextStyles.headline3, textAlign: TextAlign.center),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Add books from the Explore tab to see them here.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final readingList = snapshot.data!;
          // ListView'in padding'ini buradan alıp kartlara verdik,
          // böylece kaydırma arka planı tam genişlikte olabilir.
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
            itemCount: readingList.length,
            itemBuilder: (context, index) {
              final book = readingList[index];
              return Dismissible(
                key: Key(book.id),
                background: _buildSwipeActionRight(),
                secondaryBackground: _buildSwipeActionLeft(),
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    await _databaseService.deleteFromReadingList(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} removed from list.')),
                    );
                  }
                },
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _markAsRead(book);
                    return false;
                  }
                  return true;
                },
                child: _buildBookListItem(book),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookListItem(Book book) {
    return Card(
      margin: const EdgeInsets.only(top: AppConstants.paddingSmall, bottom: AppConstants.paddingSmall),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  child: Image.network(book.coverUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      book.author,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(Book book) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => const RatingModal(),
      isScrollControlled: true,
    );

    if (result != null && mounted) {
      final int rating = result['rating'];
      final String notes = result['notes'];

      await _databaseService.addBookToExhibition(book, rating, notes);
      await _databaseService.deleteFromReadingList(book.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved ${book.title} to your Exhibition!')),
      );
    }
  }

  // --- GÜNCELLENEN KAYDIRMA ARKA PLANLARI ---
  // Artık kart ile aynı şekle ve boşluğa sahipler.

  Widget _buildSwipeActionRight() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.paddingSmall, bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Text('Mark as Read', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSwipeActionLeft() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.paddingSmall, bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }
}