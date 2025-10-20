// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
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

  Future<List<Book>>? _newAndNotableFuture;
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
      _newAndNotableFuture = _fetchAndFilterBooks(_bookService.fetchNewAndNotable, readBookIds);
      _bestsellersFuture = _fetchAndFilterBooks(_bookService.fetchNytBestsellers, readBookIds);
      _sciFiFuture = _fetchAndFilterBooks(() => _bookService.fetchBooksByGenre('science fiction'), readBookIds);
    });
  }

  Future<List<Book>> _fetchAndFilterBooks(Future<List<dynamic>> Function() fetcher, Set<String> readBookIds) async {
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

  // --- GÜNCELLENEN AppBar OLUŞTURMA METODU ---
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isSearchOpen
            ? _buildSearchBar() // Arama açıkken gösterilecek AppBar
            : _buildTitleBar(),  // Normal durumda gösterilecek AppBar
      ),
    );
  }

  // YENİ: Başlığı gösteren standart AppBar
  Widget _buildTitleBar() {
    return CustomAppBar(
      key: const ValueKey('titleBar'), // Animasyon için anahtar
      title: 'Lector',
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () {
            setState(() { _isSearchOpen = true; });
          },
        ),
      ],
    );
  }

  // YENİ: Arama çubuğunu gösteren AppBar
  Widget _buildSearchBar() {
    return AppBar(
      key: const ValueKey('searchBar'), // Animasyon için anahtar
      leading: null, // Geri butonunu kaldır
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search books or authors...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
      // Scaffold'un kendi AppBar'ını kullanıyoruz
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('New & Notable'),
            const SizedBox(height: 12),
            _buildHorizontalBookList(_newAndNotableFuture),
            const SizedBox(height: 24),
            _buildSectionTitle('NYT Bestsellers'),
            const SizedBox(height: 12),
            _buildHorizontalBookList(_bestsellersFuture),
            const SizedBox(height: 24),
            _buildSectionTitle('Science Fiction & Fantasy'),
            const SizedBox(height: 12),
            _buildHorizontalBookList(_sciFiFuture),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return const Center(child: Text('No new books found.'));
    }
    return ListView.builder(
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final book = _searchResults![index];
        return ListTile(
          leading: Image.network(book.coverUrl, fit: BoxFit.cover, width: 50, height: 80),
          title: Text(book.title),
          subtitle: Text(book.author),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHorizontalBookList(Future<List<Book>>? future) {
    if (future == null) {
      return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SizedBox(height: 240, child: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (snapshot.hasData) {
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const SizedBox(height: 240, child: Center(child: Text('No new books to show.')));
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
                      MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
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