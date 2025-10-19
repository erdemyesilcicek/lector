// lib/features/explore/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  late Stream<bool> _isInReadingListStream;
  late Stream<ExhibitionBook?> _exhibitionBookStream;

  @override
  void initState() {
    super.initState();
    _isInReadingListStream = _databaseService.isBookInReadingList(widget.book.id);
    _exhibitionBookStream = _databaseService.getExhibitionBookStream(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
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
                    image: NetworkImage(book.coverUrl),
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
              const SizedBox(height: 24),

              // --- BOOK INFO ---
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${book.author}',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),

              // --- DİNAMİK EYLEM BUTONLARI VEYA KİŞİSEL BİLGİLER ---
              StreamBuilder<ExhibitionBook?>(
                stream: _exhibitionBookStream,
                builder: (context, exhibitionSnapshot) {
                  final exhibitionBook = exhibitionSnapshot.data;

                  if (exhibitionBook != null) {
                    return _buildExhibitionDetails(exhibitionBook);
                  }

                  return StreamBuilder<bool>(
                    stream: _isInReadingListStream,
                    builder: (context, readingListSnapshot) {
                      final isInReadingList = readingListSnapshot.data ?? false;
                      return _buildActionButtons(book, isInReadingList);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- SUMMARY ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About this book',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                book.summary,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Book book, bool isInReadingList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // MARK AS READ BUTONU
        ElevatedButton.icon(
          onPressed: () async {
            final result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              builder: (context) => const RatingModal(),
              isScrollControlled: true,
            );

            if (result != null && mounted) {
              final int rating = result['rating'];
              final String notes = result['notes'];

              await _databaseService.addBookToExhibition(book, rating, notes);
              
              if(isInReadingList) {
                await _databaseService.deleteFromReadingList(book.id);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to your Exhibition!')),
              );
            }
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

        // ADD TO LIST VEYA REMOVE BUTONU
        isInReadingList
            ? OutlinedButton.icon(
                onPressed: () {
                   _databaseService.deleteFromReadingList(book.id);
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from your Reading List!')),
                  );
                },
                icon: const Icon(Icons.bookmark_remove_outlined),
                label: const Text('Remove'),
                 style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
              )
            : OutlinedButton.icon(
                onPressed: () {
                  _databaseService.addBookToReadingList(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to your Reading List!')),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Add to List'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
      ],
    );
  }

  // --- GÜNCELLENEN METOT ---
  // Artık "Edit" butonunu ve mantığını içeriyor.
  Widget _buildExhibitionDetails(ExhibitionBook exhibitionBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Rating', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        const Text('Your Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            exhibitionBook.notes.isEmpty ? 'No notes added for this book.' : exhibitionBook.notes,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontStyle: exhibitionBook.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: exhibitionBook.notes.isEmpty ? Colors.grey.shade700 : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => RatingModal(
                    initialRating: exhibitionBook.rating,
                    initialNotes: exhibitionBook.notes,
                  ),
                  isScrollControlled: true,
                );

                if (result != null && mounted) {
                  final int newRating = result['rating'];
                  final String newNotes = result['notes'];

                  await _databaseService.updateExhibitionBook(exhibitionBook.id, newRating, newNotes);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your rating has been updated!')),
                  );
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Rating'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () async {
                await _databaseService.deleteFromExhibition(exhibitionBook.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${exhibitionBook.title} removed from Exhibition.')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}