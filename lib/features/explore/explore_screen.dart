// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/book_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();
  final _searchController = TextEditingController();
  
  // DÜZELTME: Artık 'late' değil ve tek bir Future'ımız var.
  Future<List<Book>>? _trendingBooksFuture; 
  List<Book>? _searchResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Yükleme işlemini initState içinde başlatıyoruz.
    _trendingBooksFuture = _loadInitialData();
  }

  // DÜZELTME: Tüm başlangıç verisini yükleyen tek bir metot.
  Future<List<Book>> _loadInitialData() async {
    // Önce okunan kitapların ID'lerini al
    final readBookIds = await _databaseService.getReadBookIds();
    // Sonra trend olan kitapları al
    final booksJson = await _bookService.fetchTrendingBooks();
    // Okunmamış olanları filtreleyip geri döndür
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
    setState(() { _isLoading = true; });
    
    // Aramadan önce de okunan kitapları kontrol edelim
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
  
  // KODUN GERİ KALANI AYNI
  // ... build, _buildDefaultContent, _buildSearchResults, etc. ...
  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchResults != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                onSubmitted: _performSearch,
              ),
              const SizedBox(height: 24),
              
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
          _buildHorizontalBookList(_trendingBooksFuture!),
        ],
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
          if (books.isEmpty){
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