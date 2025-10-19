// lib/core/models/book_model.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final List<String> genres; // YENİ ALAN

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.genres, // YENİ
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    // API'den gelen kategorileri alıp List<String>'e çeviriyoruz
    final categories = (volumeInfo['categories'] as List<dynamic>?)
        ?.map((e) => e.toString())
        ?.toList() ?? [];

    return Book(
      id: json['id'] ?? 'Unknown ID',
      title: volumeInfo['title'] ?? 'No Title',
      author: (volumeInfo['authors'] as List<dynamic>?)?.first ?? 'Unknown Author',
      coverUrl: imageLinks['thumbnail'] ?? 'https://i.imgur.com/J5LVHEL.png', // Daha iyi bir placeholder
      genres: categories, // YENİ
    );
  }
}