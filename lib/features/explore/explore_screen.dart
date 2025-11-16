// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/features/explore/explore_big_card.dart';
import 'package:lector/widgets/book_card_widget.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/rating_modal_widget.dart';
import 'package:lector/widgets/shimmer_loading.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Book>>? _fantasyBooksFuture;
  Future<List<Book>>? _sciFiBooksFuture;
  Future<List<Book>>? _thrillerBooksFuture;
  Future<List<Book>>? _classicsFuture;

  Set<String> _readBookIds = {};
  Set<String> _readingListIds = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    _readBookIds = await _databaseService.getReadBookIds();
    final readingList = await _databaseService.getReadingListStream().first;
    _readingListIds = readingList.map((b) => b.id).toSet();
    final excludedIds = _readBookIds.union(_readingListIds);

    setState(() {
      _fantasyBooksFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('fantasy fiction bestseller'),
        excludedIds,
      );
      _sciFiBooksFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('science fiction bestseller'),
        excludedIds,
      );
      _thrillerBooksFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('thriller suspense bestseller'),
        excludedIds,
      );
      _classicsFuture = _fetchAwardWinnersAndFilter(excludedIds);
    });
  }

  Future<List<Book>> _fetchAwardWinnersAndFilter(
    Set<String> excludedIds,
  ) async {
    final books = await _bookService.fetchAwardWinners();
    return books.where((book) => !excludedIds.contains(book.id)).toList();
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
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge,
                bottom: AppConstants.paddingSmall,
              ),
              child: Text('Classics', style: theme.textTheme.headlineSmall),
            ),
            _buildHorizontalBigCardList(_classicsFuture),

            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge,
                bottom: AppConstants.paddingMedium,
              ),
              child: Text('Fantasy', style: theme.textTheme.headlineSmall),
            ),
            _buildHorizontalBookList(_fantasyBooksFuture),

            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge,
                bottom: AppConstants.paddingMedium,
              ),
              child: Text(
                'Science Fiction',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            _buildHorizontalBookList(_sciFiBooksFuture),

            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge,
                bottom: AppConstants.paddingMedium,
              ),
              child: Text('Thriller', style: theme.textTheme.headlineSmall),
            ),
            _buildHorizontalBookList(_thrillerBooksFuture),

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
      return SizedBox(
        height: cardHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: cardWidth,
              margin: const EdgeInsets.only(
                right: AppConstants.paddingMedium,
              ),
              child: const BigCardShimmer(),
            );
          },
        ),
      );
    }

    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(
                    right: AppConstants.paddingMedium,
                  ),
                  child: const BigCardShimmer(),
                );
              },
            ),
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
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved to your Exhibition!'),
                              ),
                            );
                          }
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

  Widget _buildHorizontalBookList(Future<List<Book>>? future) {
    final theme = Theme.of(context);

    if (future == null) {
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium + AppConstants.paddingSmall / 2,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(
                right: AppConstants.paddingMedium,
              ),
              child: BookCardShimmer(),
            );
          },
        ),
      );
    }

    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium + AppConstants.paddingSmall / 2,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    right: AppConstants.paddingMedium,
                  ),
                  child: const BookCardShimmer(),
                );
              },
            ),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Could not load books.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'No new books to show.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final books = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: AppConstants.paddingMedium + AppConstants.paddingSmall / 2,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.paddingMedium,
                ),
                child: SizedBox(
                  width: 130,
                  child: BookCard(
                    key: ValueKey(book.id),
                    title: book.title,
                    author: book.author,
                    coverUrl: book.coverUrl,
                    showAwardBadge: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
