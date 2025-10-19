// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/book_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookService _bookService = BookService();
  final _searchController = TextEditingController();
  
  late Future<List<Book>> _trendingBooksFuture;
  List<Book>? _searchResults; // Nullable list to hold search results
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trendingBooksFuture = _fetchTrendingBooks();
  }

  Future<List<Book>> _fetchTrendingBooks() async {
    final booksJson = await _bookService.fetchTrendingBooks();
    return booksJson.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null; // Clear results if query is empty
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final booksJson = await _bookService.searchBooks(query);
    setState(() {
      _searchResults = booksJson.map((json) => Book.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show search results or the default content
    final bool isSearching = _searchResults != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEARCH BAR ---
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for books or authors...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                // This triggers the search when the user submits
                onSubmitted: _performSearch,
              ),
              const SizedBox(height: 24),
              
              // --- DYNAMIC CONTENT AREA ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isSearching
                        ? _buildSearchResults()
                        : _buildDefaultContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Trending Now'),
          const SizedBox(height: 12),
          _buildHorizontalBookList(_trendingBooksFuture),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return const Center(child: Text('No books found.'));
    }
    // A vertical list for search results
    return ListView.builder(
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final book = _searchResults![index];
        return ListTile(
          leading: Image.network(book.coverUrl, fit: BoxFit.cover, width: 50),
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
      title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHorizontalBookList(Future<List<Book>> future) {
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