// lib/features/home/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/book_card_widget.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // SINIF ADI GÜNCELLENDİ
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();
  final _searchController = TextEditingController();

  Future<Book?>? _bookOfTheDayFuture;
  Future<List<Book>>? _bestsellersFuture;
  Future<List<Book>>? _sciFiFuture;

  List<Book>? _searchResults;
  bool _isLoading = false;
  bool _isSearchOpen = false;
  Set<String> _readBookIds = {};
  Set<String> _readingListIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _readBookIds = await _databaseService.getReadBookIds();
    final readingList = await _databaseService.getReadingListStream().first;
    _readingListIds = readingList.map((b) => b.id).toSet();
    final excludedIds = _readBookIds.union(_readingListIds);

    setState(() {
      _bookOfTheDayFuture = _bookService.fetchBookOfTheDay();
      _bestsellersFuture = _fetchNytBestsellersAndFilter(excludedIds);
      _sciFiFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('science fiction'),
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

  Future<List<Book>> _fetchNytBestsellersAndFilter(
    Set<String> excludedIds,
  ) async {
    final booksJson = await _bookService.fetchRealNytBestsellersJson();
    return booksJson
        .map((json) => Book.fromNytJson(json))
        .where((book) => !excludedIds.contains(book.id))
        .toList();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    _readBookIds = await _databaseService.getReadBookIds();
    final readingList = await _databaseService.getReadingListStream().first;
    _readingListIds = readingList.map((b) => b.id).toSet();
    final excludedIds = _readBookIds.union(_readingListIds);

    final booksJson = await _bookService.searchBooks(query);

    setState(() {
      _searchResults = booksJson
          .map((json) => Book.fromJson(json))
          .where((book) => !excludedIds.contains(book.id))
          .toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isSearchOpen
            ? AppBar(
                key: const ValueKey('searchBar'),
                leading: null,
                automaticallyImplyLeading: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search books or authors...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.bodyLarge,
                  onSubmitted: _performSearch,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = false;
                        _searchResults = null;
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              )
            : CustomAppBar(
                key: const ValueKey('titleBar'),
                title: 'Lector',
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = true;
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchResults != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isSearching
          ? _buildSearchResults()
          : _buildDefaultContent(),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookOfTheDaySection(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.paddingLarge),
                _buildSectionTitle('NYT Bestsellers'),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildHorizontalBookList(_bestsellersFuture),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildSectionTitle('Science Fiction & Fantasy'),
                const SizedBox(height: AppConstants.paddingMedium),
                _buildHorizontalBookList(_sciFiFuture),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookOfTheDaySection() {
    return FutureBuilder<Book?>(
      future: _bookOfTheDayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final book = snapshot.data!;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingSmall,
          ),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book: book),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(book.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        padding: const EdgeInsets.all(
                          AppConstants.paddingMedium,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium,
                                ),
                                child: Image.network(
                                  book.coverUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Chip(
                                    label: Text(
                                      'Book of the Day',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    backgroundColor: theme.colorScheme.surface
                                        .withOpacity(0.8),
                                    side: BorderSide(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppConstants.paddingSmall / 2,
                                  ),
                                  Text(
                                    book.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        const Shadow(
                                          blurRadius: 3,
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: AppConstants.paddingSmall / 2,
                                  ),
                                  Text(
                                    book.author,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    if (_searchResults == null || _searchResults!.isEmpty) {
      return Center(
        child: Text(
          'No new books found.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final book = _searchResults![index];
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              child: Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null
                    ? child
                    : Center(
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) =>
                    GeneratedCover(title: book.title, author: book.author),
              ),
            ),
          ),
          title: Text(
            book.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(book.author, style: theme.textTheme.bodySmall),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(book: book),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.paddingSmall / 2),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildHorizontalBookList(Future<List<Book>>? future) {
    final theme = Theme.of(context);
    if (future == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          final books = snapshot.data!;
          if (books.isEmpty) {
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
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: AppConstants.paddingSmall / 2,
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
                      title: book.title,
                      author: book.author,
                      coverUrl: book.coverUrl,
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
        }
        return const SizedBox.shrink();
      },
    );
  }
}
