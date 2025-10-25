// lib/features/explore/book_detail_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
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
    _isInReadingListStream = _databaseService.isBookInReadingList(
      widget.book.id,
    );
    _exhibitionBookStream = _databaseService.getExhibitionBookStream(
      widget.book.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.white.withOpacity(0.7);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: ''),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(book.coverUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.75)),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    Container(
                      width: 210,
                      height: 315,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                        child: Image.network(book.coverUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 1.5),

                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(blurRadius: 5, color: Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'by ${book.author}',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 1.5),
                    StreamBuilder<ExhibitionBook?>(
                      stream: _exhibitionBookStream,
                      builder: (context, snapshot) {
                        final exhibitionBook = snapshot.data;
                        if (exhibitionBook != null) {
                          return _buildExhibitionDetails(
                            exhibitionBook,
                            theme,
                            primaryTextColor,
                            secondaryTextColor,
                          );
                        }
                        return StreamBuilder<bool>(
                          stream: _isInReadingListStream,
                          builder: (context, snapshot) {
                            final isInReadingList = snapshot.data ?? false;
                            return _buildActionButtons(
                              book,
                              isInReadingList,
                              theme,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    Divider(color: secondaryTextColor.withOpacity(0.5)),
                    const SizedBox(height: AppConstants.paddingLarge),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About this book',
                        style: textTheme.headlineSmall?.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      book.summary.isEmpty
                          ? 'No summary available.'
                          : book.summary,
                      style: textTheme.bodyLarge?.copyWith(
                        color: secondaryTextColor,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Book book, bool isInReadingList, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                backgroundColor: Colors.black,
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
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingMedium,
              ),
              backgroundColor: colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              'Mark as Read',
              style: textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),

        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              if (isInReadingList) {
                _databaseService.deleteFromReadingList(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from your Reading List!'),
                  ),
                );
              } else {
                _databaseService.addBookToReadingList(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to your Reading List!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingMedium,
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              elevation: 1,
            ),
            child: Text(
              isInReadingList ? 'Remove' : 'Add to List',
              style: textTheme.labelLarge?.copyWith(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExhibitionDetails(
    ExhibitionBook exhibitionBook,
    ThemeData theme,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    void openEditModal() async {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: Colors.transparent,
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
          exhibitionBook.id,
          newRating,
          newNotes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your rating has been updated!')),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: openEditModal,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingSmall,
            ),
            child: Row(
              children: [
                Icon(Icons.star_half_rounded, color: AppColors.star, size: 22),
                const SizedBox(width: AppConstants.paddingMedium),
                Text(
                  'Your Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < exhibitionBook.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.star,
                      size: 26,
                    );
                  }),
                ),
                const SizedBox(width: AppConstants.paddingSmall / 2),
                Icon(Icons.edit_outlined, color: secondaryTextColor, size: 18),
              ],
            ),
          ),
        ),

        if (exhibitionBook.notes.isNotEmpty) ...[
          Divider(color: secondaryTextColor.withOpacity(0.3)),
          InkWell(
            onTap: openEditModal,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.notes_rounded,
                      color: AppColors.star,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Text(
                      exhibitionBook.notes,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryTextColor.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: AppConstants.paddingLarge),

        OutlinedButton.icon(
          onPressed: () async {
            await _databaseService.deleteFromExhibition(exhibitionBook.id);
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from Exhibition')),
              );
            }
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Remove from Exhibition'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingSmall,
            ),
          ),
        ),
      ],
    );
  }
}
