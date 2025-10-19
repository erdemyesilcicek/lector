// lib/features/explore/book_detail_screen.dart

import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  // This screen will receive data from the card that was tapped.
  // We add these parameters to its constructor.
  final String title;
  final String author;
  final String coverUrl;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The back button is automatically added by Flutter
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- BOOK COVER ---
              Container(
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(coverUrl),
                    fit: BoxFit.contain,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                // Adding a slight shadow for depth
                child: Container(
                  decoration: BoxDecoration(
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
              const SizedBox(height: 24),

              // --- BOOK INFO ---
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by $author',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),

              // --- ACTION BUTTONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Primary action button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement "Mark as Read" functionality
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark as Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Secondary action button
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement "Add to Reading List" functionality
                    },
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Add to List'),
                     style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- SUMMARY ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About this book',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                // Placeholder summary text
                'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the “spice” melange, a drug capable of extending life and enhancing consciousness. Coveted across the known universe, melange is a prize worth killing for...',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}