// lib/features/reading_list/reading_list_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading List'),
      ),
      body: StreamBuilder<List<Book>>(
        stream: _databaseService.getReadingListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your reading list is empty.\nAdd books from the Explore tab!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final readingList = snapshot.data!;
          return ListView.builder(
            itemCount: readingList.length,
            itemBuilder: (context, index) {
              final book = readingList[index];
              // Use Dismissible to add swipe actions
              return Dismissible(
                key: Key(book.id), // Unique key for each item
                background: _buildSwipeActionLeft(), // Swipe Right to Left (Delete)
                secondaryBackground: _buildSwipeActionRight(), // Swipe Left to Right (Mark as Read)
                
                // This function is called when a swipe is completed
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    // Swiped Left (Delete)
                    await _databaseService.deleteFromReadingList(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} removed from list.')),
                    );
                  }
                },

                // This function allows us to intercept a swipe before it completes
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Swiped Right (Mark as Read)
                    await _markAsRead(book);
                    return false; // Don't actually dismiss, we handle removal manually
                  }
                  // For delete, return true to allow the dismiss
                  return true;
                },

                child: ListTile(
                  leading: Image.network(book.coverUrl, fit: BoxFit.cover, width: 50, height: 80),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () {
                    // Navigate to detail screen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to show the rating modal and handle the logic
  Future<void> _markAsRead(Book book) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => const RatingModal(),
      isScrollControlled: true,
    );

    if (result != null && mounted) {
      final int rating = result['rating'];
      final String notes = result['notes'];

      // 1. Add to exhibition
      await _databaseService.addBookToExhibition(book, rating, notes);
      // 2. Remove from reading list
      await _databaseService.deleteFromReadingList(book.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved ${book.title} to your Exhibition!')),
      );
    }
  }

// UI for the swipe right background (Mark as Read)
  Widget _buildSwipeActionRight() {
    return Container(
      color: Colors.green, // Green for "Mark as Read"
      alignment: Alignment.centerLeft, // Align content to the left
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Row(
        // Icon and text are at the start of the row
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Text('Mark as Read', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// UI for the swipe left background (Remove)
  Widget _buildSwipeActionLeft() {
    return Container(
      color: Colors.red, // Red for "Remove"
      alignment: Alignment.centerRight, // Align content to the right
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Row(
        // Icon and text are at the end of the row
        mainAxisAlignment: MainAxisAlignment.end, 
        children: [
          Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }
}