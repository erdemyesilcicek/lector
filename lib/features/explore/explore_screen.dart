// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/widgets/book_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea ensures content is not blocked by notches or system bars
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEARCH BAR ---
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

              // --- TRENDING NOW SECTION ---
              _buildSectionTitle('Trending Now'),
              const SizedBox(height: 12),
              _buildHorizontalBookList(),
              
              const SizedBox(height: 24),

              // --- NEW RELEASES SECTION ---
              _buildSectionTitle('New Releases'),
              const SizedBox(height: 12),
              _buildHorizontalBookList(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Helper widget for the horizontal book list
  Widget _buildHorizontalBookList() {
    return SizedBox(
      height: 240, // Height of the list container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          // Placeholder data - will be replaced by API data later
          return BookCard(
            title: 'Dune',
            author: 'Frank Herbert',
            coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1555447414l/44767458.jpg',
            onTap: () {
              // TODO: Navigate to book detail screen
            },
          );
        },
      ),
    );
  }
}