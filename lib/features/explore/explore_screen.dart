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
  late Future<List<Book>> _trendingBooksFuture;

  @override
  void initState() {
    super.initState();
    // Fetch books when the screen is first created
    _trendingBooksFuture = _fetchBooks();
  }

  Future<List<Book>> _fetchBooks() async {
    final booksJson = await _bookService.fetchTrendingBooks();
    // Convert the JSON list to a list of Book objects
    return booksJson.map((json) => Book.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Search Bar remains the same)
              TextField(
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
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Trending Now'),
              const SizedBox(height: 12),
              // Use a FutureBuilder to handle the asynchronous API call
              _buildHorizontalBookList(_trendingBooksFuture),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHorizontalBookList(Future<List<Book>> future) {
    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        // While waiting for data, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // If an error occurred, show an error message
        if (snapshot.hasError) {
          return SizedBox(
            height: 240,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        // If data is available, build the list
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
                      MaterialPageRoute(
                        // Pass the entire 'book' object to the detail screen
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
        // By default, show an empty container
        return const SizedBox.shrink();
      },
    );
  }
}
