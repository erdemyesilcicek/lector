// lib/features/explore/explore_screen.dart

import 'dart:ui'; // ImageFilter.blur için gerekli
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/book_card_widget.dart';
import 'package:lector/widgets/custom_app_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();
  final _searchController = TextEditingController();

  Future<Book?>? _bookOfTheDayFuture;
  Future<List<Book>>? _bestsellersFuture;
  Future<List<Book>>? _sciFiFuture;

  List<Book>? _searchResults;
  bool _isLoading = false;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final readBookIds = await _databaseService.getReadBookIds();
    setState(() {
      _bookOfTheDayFuture = _bookService.fetchBookOfTheDay();
      _bestsellersFuture = _fetchAndFilterBooks(
        _bookService.fetchNytBestsellers,
        readBookIds,
      );
      _sciFiFuture = _fetchAndFilterBooks(
        () => _bookService.fetchBooksByGenre('science fiction'),
        readBookIds,
      );
    });
  }

  Future<List<Book>> _fetchAndFilterBooks(
    Future<List<dynamic>> Function() fetcher,
    Set<String> readBookIds,
  ) async {
    final booksJson = await fetcher();
    return booksJson
        .map((json) => Book.fromJson(json))
        .where((book) => !readBookIds.contains(book.id))
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

    final readBookIds = await _databaseService.getReadBookIds();
    final booksJson = await _bookService.searchBooks(query);

    setState(() {
      _searchResults = booksJson
          .map((json) => Book.fromJson(json))
          .where((book) => !readBookIds.contains(book.id))
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
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isSearchOpen ? _buildSearchBar() : _buildTitleBar(),
      ),
    );
  }

  Widget _buildTitleBar() {
    return CustomAppBar(
      key: const ValueKey('titleBar'),
      title: 'Lector',
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () {
            setState(() {
              _isSearchOpen = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AppBar(
      key: const ValueKey('searchBar'),
      leading: null,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search books or authors...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
        ),
        style: AppTextStyles.bodyLarge,
        onSubmitted: _performSearch,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () {
            setState(() {
              _isSearchOpen = false;
              _searchResults = null;
              _searchController.clear();
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchResults != null;

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,
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

  // --- GÜNCELLENEN "Günün Kitabı" Bölümü ---
  Widget _buildBookOfTheDaySection() {
    return FutureBuilder<Book?>(
      future: _bookOfTheDayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Yükleme iskeleti
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Container(height: 250, color: Colors.grey.shade200),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final book = snapshot.data!;
        // --- YENİ: Kart yapısı için Padding ve Card eklendi ---
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
            clipBehavior: Clip
                .antiAlias, // Bu, içindeki her şeyin kartın köşelerine uymasını sağlar
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book: book),
                  ),
                );
              },
              child: Container(
                height: 250,
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
                      color: Colors.black.withOpacity(
                        0.25,
                      ), // Opaklığı biraz artırdık
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusMedium,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 15,
                                  offset: Offset(5, 5),
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
                                // --- YENİ: Chip tasarımı güncellendi ---
                                Chip(
                                  label: Text(
                                    'Book of the Day',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.paddingSmall,
                                ),
                                Text(
                                  book.title,
                                  style: AppTextStyles.headline2.copyWith(
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 5,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: AppConstants.paddingSmall,
                                ),
                                Text(
                                  book.author,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
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
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return const Center(child: Text('No new books found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final book = _searchResults![index];
        return ListTile(
          leading: Image.network(
            book.coverUrl,
            fit: BoxFit.cover,
            width: 50,
            height: 80,
          ),
          title: Text(
            book.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(book.author, style: AppTextStyles.bodySmall),
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
    return Text(title, style: AppTextStyles.headline3);
  }

  Widget _buildHorizontalBookList(Future<List<Book>>? future) {
    if (future == null) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 240,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (snapshot.hasData) {
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const SizedBox(
              height: 240,
              child: Center(child: Text('No new books to show.')),
            );
          }
          return SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCard(
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
