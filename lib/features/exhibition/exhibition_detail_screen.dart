// lib/features/exhibition/exhibition_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/database_service.dart'; // Import service

class ExhibitionDetailScreen extends StatefulWidget { // Changed to StatefulWidget
  final ExhibitionBook exhibitionBook;

  const ExhibitionDetailScreen({
    super.key,
    required this.exhibitionBook,
  });

  @override
  State<ExhibitionDetailScreen> createState() => _ExhibitionDetailScreenState();
}

class _ExhibitionDetailScreenState extends State<ExhibitionDetailScreen> { // State class
  final DatabaseService _databaseService = DatabaseService(); // Moved service here

  @override
  Widget build(BuildContext context) {
    // Access the book via widget.exhibitionBook
    final exhibitionBook = widget.exhibitionBook;

    return Scaffold(
      appBar: AppBar(
        title: Text(exhibitionBook.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (The rest of the UI remains the same)
            Center(
              child: Container(
                height: 300,
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(exhibitionBook.coverUrl),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(12),
                   boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    )
                  ],
                ),
              ),
            ),
            
            const Text(
              'Your Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < exhibitionBook.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                );
              }),
            ),
            const SizedBox(height: 24),

            const Text(
              'Your Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exhibitionBook.notes.isEmpty 
                  ? 'No notes added for this book.' 
                  : exhibitionBook.notes,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontStyle: exhibitionBook.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
                  color: exhibitionBook.notes.isEmpty ? Colors.grey.shade700 : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- DELETE BUTTON ---
            Center(
              child: TextButton.icon(
                // UPDATED onPressed
                onPressed: () async {
                  // Call the service to delete the book
                  await _databaseService.deleteFromExhibition(exhibitionBook.id);
                  
                  // After deleting, close the detail screen
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${exhibitionBook.title} removed from Exhibition.')),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove from Exhibition'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}