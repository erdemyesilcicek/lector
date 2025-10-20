// lib/core/models/book_model.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String summary; // YENİ ALAN
  final List<String> genres;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.summary, // YENİ
    required this.genres,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    final description = volumeInfo['description'] ?? 'No summary available.'; // API'den özet çekiyoruz
    
    final categories = (volumeInfo['categories'] as List<dynamic>?)
        ?.map((e) => e.toString())
        ?.toList() ?? [];

    return Book(
      id: json['id'] ?? 'Unknown ID',
      title: volumeInfo['title'] ?? 'No Title',
      author: (volumeInfo['authors'] as List<dynamic>?)?.first ?? 'Unknown Author',
      coverUrl: imageLinks['thumbnail'] ?? 'https://i.imgur.com/J5LVHEL.png',
      summary: description, // YENİ
      genres: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volumeInfo': {
        'title': title,
        'authors': [author],
        'description': summary,
        'categories': genres,
        'imageLinks': {'thumbnail': coverUrl},
      },
    };
  }
}