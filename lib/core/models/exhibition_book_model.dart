// lib/core/models/exhibition_book_model.dart

class ExhibitionBook {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final int rating;
  final String notes;

  ExhibitionBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.rating,
    required this.notes,
  });

  // A factory constructor to create an ExhibitionBook from a Firestore document
  factory ExhibitionBook.fromDoc(Map<String, dynamic> data, String docId) {
    return ExhibitionBook(
      id: docId,
      title: data['title'] ?? 'No Title',
      author: data['author'] ?? 'No Author',
      coverUrl: data['coverUrl'] ?? '',
      rating: data['rating'] ?? 0,
      notes: data['notes'] ?? '',
    );
  }
}