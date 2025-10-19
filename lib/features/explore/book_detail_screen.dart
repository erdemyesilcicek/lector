// lib/features/explore/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/widgets/rating_modal_widget.dart';

// The widget itself now just holds the final data
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

// lib/features/explore/book_detail_screen.dart dosyasının içindeki State sınıfı

class _BookDetailScreenState extends State<BookDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  // Durumları dinlemek için Stream'ler ve değişkenler
  late Stream<bool> _isInReadingListStream;
  late Stream<bool> _isInExhibitionStream;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında dinlemeye başla
    _isInReadingListStream = _databaseService.isBookInReadingList(
      widget.book.id,
    );
    _isInExhibitionStream = _databaseService.isBookInExhibition(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BOOK INFO ---
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${book.author}',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),

              // --- DİNAMİK EYLEM BUTONLARI ---
              StreamBuilder<bool>(
                stream: _isInExhibitionStream,
                builder: (context, exhibitionSnapshot) {
                  final isInExhibition = exhibitionSnapshot.data ?? false;

                  // Eğer kitap sergideyse, bir bilgi mesajı göster ve başka buton gösterme
                  if (isInExhibition) {
                    return const Chip(
                      label: Text('You have read this book'),
                      avatar: Icon(Icons.check_circle, color: Colors.green),
                      padding: EdgeInsets.all(12),
                    );
                  }

                  // Eğer sergide değilse, "Reading List" durumunu kontrol et
                  return StreamBuilder<bool>(
                    stream: _isInReadingListStream,
                    builder: (context, readingListSnapshot) {
                      final isInReadingList = readingListSnapshot.data ?? false;
                      // Duruma göre butonları oluştur
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
              const Text(
                'Summary will be displayed here once it is added to the Book model.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Butonları oluşturan yardımcı metot
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

              // Eğer kitap okuma listesindeyse, oradan da sil
              if (isInReadingList) {
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

        // ADD TO LIST BUTONU (DİNAMİK)
        isInReadingList
            ? OutlinedButton.icon(
                onPressed: () {
                  _databaseService.deleteFromReadingList(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from your Reading List!'),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_remove_outlined),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: () {
                  _databaseService.addBookToReadingList(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to your Reading List!'),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Add to List'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
      ],
    );
  }
}
