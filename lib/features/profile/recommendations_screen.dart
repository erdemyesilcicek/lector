// lib/features/profile/recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart';
import 'package:lector/widgets/custom_app_bar.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late final Future<List<Book>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = _databaseService.getRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:'Recommendations'),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Book>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not generate recommendations.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Not enough data to generate recommendations.\nRead and rate more books!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final recommendations = snapshot.data!;
          return ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final book = recommendations[index];
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
        },
      ),
    );
  }
}