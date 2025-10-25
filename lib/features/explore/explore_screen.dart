// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/explore_big_card.dart';
import 'package:lector/features/explore/explore_card.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();
  Future<List<Book>>? _fantasyBooksFuture;

  Set<String> _readBookIds = {};
  Set<String> _readingListIds = {};

  @override
  void initState() {
    super.initState();
    _loadFantasyBooks();
  }

  Future<void> _loadFantasyBooks() async {
    _readBookIds = await _databaseService.getReadBookIds();
    final readingList = await _databaseService.getReadingListStream().first;
    _readingListIds = readingList.map((b) => b.id).toSet();
    final excludedIds = _readBookIds.union(_readingListIds);

    setState(() {
      _fantasyBooksFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('fantasy'),
        excludedIds,
      );
    });
  }

  Future<List<Book>> _fetchGoogleBooksAndFilter(
    Future<List<dynamic>> Function() fetcher,
    Set<String> excludedIds,
  ) async {
    final booksJson = await fetcher();
    return booksJson
        .map((json) => Book.fromJson(json))
        .where((book) => !excludedIds.contains(book.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Explore'),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Text('Categories', style: theme.textTheme.headlineSmall),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              crossAxisCount: 3,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
              childAspectRatio: 0.9,
              children: <Widget>[
                ExploreCard(
                  iconAssetPath: 'assets/images/sci-fi.png',
                  text: 'Sci-Fi',
                  onTap: () {
                    print('Sci-Fi tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/thriller.png',
                  text: 'Thriller',
                  onTap: () {
                    print('Thriller tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/romance.png',
                  text: 'Romance',
                  onTap: () {
                    print('Romance tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/fantasy.png',
                  text: 'Fantasy',
                  onTap: () {
                    print('Fantasy tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/religion.png',
                  text: 'Religion',
                  onTap: () {
                    print('Religion tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/history.png',
                  text: 'History',
                  onTap: () {
                    print('History tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/detective.png',
                  text: 'Detective',
                  onTap: () {
                    print('Detective tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/science.png',
                  text: 'Science',
                  onTap: () {
                    print('Science tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/images/children.png',
                  text: 'Children',
                  onTap: () {
                    print('Children tıklandı');
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge,
                bottom: AppConstants.paddingSmall,
              ),
              child: Text('Classics', style: theme.textTheme.headlineSmall),
            ),
            _buildHorizontalBigCardList(_fantasyBooksFuture),

            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBigCardList(Future<List<Book>>? future) {
    final theme = Theme.of(context);
    const double cardHeight = 280.0;
    const double cardWidth = cardHeight * 0.7;

    if (future == null) {
      return const SizedBox(
        height: cardHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: cardHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: cardHeight,
            child: Center(
              child: Text(
                'Error loading books',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: cardHeight,
            child: Center(
              child: Text(
                'No books found in this category.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final books = snapshot.data!;
        return SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return StreamBuilder<bool>(
                stream: _databaseService.isBookInReadingList(book.id),
                builder: (context, listSnapshot) {
                  final isInReadingList = listSnapshot.data ?? false;
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(
                      right: AppConstants.paddingMedium,
                    ),
                    child: ExploreBigCard(
                      book: book,
                      isInReadingList: isInReadingList,
                      onMarkAsRead: () async {
                        final result =
                            await showModalBottomSheet<Map<String, dynamic>>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const RatingModal(),
                              isScrollControlled: true,
                            );
                        if (result != null && mounted) {
                          final int rating = result['rating'];
                          final String notes = result['notes'];
                          await _databaseService.addBookToExhibition(
                            book,
                            rating,
                            notes,
                          );
                          if (isInReadingList) {
                            await _databaseService.deleteFromReadingList(
                              book.id,
                            );
                          }
                          setState(() {
                            _readBookIds.add(book.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to your Exhibition!'),
                            ),
                          );
                        }
                      },
                      onToggleReadingList: () {
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
                            const SnackBar(
                              content: Text('Added to your Reading List!'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
