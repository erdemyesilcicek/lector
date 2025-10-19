// lib/core/models/book_model.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
  });

  // A factory constructor to create a Book from the API's JSON response
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    
    return Book(
      id: json['id'] ?? 'Unknown ID',
      title: volumeInfo['title'] ?? 'No Title',
      // The API returns authors as a list, we'll take the first one
      author: (volumeInfo['authors'] as List<dynamic>?)?.first ?? 'Unknown Author',
      // Get the thumbnail image, or a placeholder if it doesn't exist
      coverUrl: imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
    );
  }
}