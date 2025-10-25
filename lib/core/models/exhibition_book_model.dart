// lib/core/models/exhibition_book_model.dart

class ExhibitionBook {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String summary;
  final List<String> genres;
  final int rating;
  final String notes;

  ExhibitionBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.summary,
    required this.genres,
    required this.rating,
    required this.notes,
  });

  factory ExhibitionBook.fromDoc(Map<String, dynamic> data, String docId) {
    return ExhibitionBook(
      id: docId,
      title: data['title'] ?? 'No Title',
      author: data['author'] ?? 'No Author',
      coverUrl: data['coverUrl'] ?? '',
      summary: data['summary'] ?? 'No summary available.',
      genres:
          (data['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: data['rating'] ?? 0,
      notes: data['notes'] ?? '',
    );
  }
}
