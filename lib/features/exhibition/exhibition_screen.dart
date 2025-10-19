// lib/features/exhibition/exhibition_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/widgets/book_card_widget.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/features/explore/book_detail_screen.dart';

class ExhibitionScreen extends StatefulWidget {
  const ExhibitionScreen({super.key});

  @override
  State<ExhibitionScreen> createState() => _ExhibitionScreenState();
}

class _ExhibitionScreenState extends State<ExhibitionScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Exhibition')),
      body: StreamBuilder<List<ExhibitionBook>>(
        stream: _databaseService.getExhibitionStream(),
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
                'Your exhibition is empty.\nMark books as read to build your gallery!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final exhibitionList = snapshot.data!;

          // Use a GridView for the gallery layout
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.6, // Adjust aspect ratio for book covers
            ),
            itemCount: exhibitionList.length,
            itemBuilder: (context, index) {
              final exBook = exhibitionList[index];
              // Use the vertical BookCard we created earlier
              return BookCard(
                title: exBook.title,
                author: exBook.author,
                coverUrl: exBook.coverUrl,
                onTap: () {
                  final bookForDetail = Book(
                    id: exBook.id,
                    title: exBook.title,
                    author: exBook.author,
                    coverUrl: exBook.coverUrl,
                    summary: exBook
                        .summary,
                    genres: exBook.genres,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookDetailScreen(book: bookForDetail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
