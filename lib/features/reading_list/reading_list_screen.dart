// lib/features/reading_list/reading_list_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/database_service.dart';

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
        // Use the stream from our service
        stream: _databaseService.getReadingListStream(),
        builder: (context, snapshot) {
          // 1. While waiting for data, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. If an error occurred, show an error message
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          // 3. If there's no data, the list is empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your reading list is empty.\nAdd books from the Explore tab!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4. If we have data, display it in a list
          final readingList = snapshot.data!;
          return ListView.builder(
            itemCount: readingList.length,
            itemBuilder: (context, index) {
              final book = readingList[index];
              return ListTile(
                leading: Image.network(book.coverUrl, fit: BoxFit.cover, width: 50),
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () {
                  // TODO: Navigate to the correct BookDetailScreen
                },
              );
            },
          );
        },
      ),
    );
  }
}