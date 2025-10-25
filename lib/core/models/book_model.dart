// lib/core/models/book_model.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String summary;
  final List<String> genres;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.summary,
    required this.genres,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    final description = volumeInfo['description'] ?? 'No summary available.';
    final categories =
        (volumeInfo['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Book(
      id: json['id'] ?? 'Unknown ID_${DateTime.now().millisecondsSinceEpoch}',
      title: volumeInfo['title'] ?? 'No Title',
      author:
          (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ??
          'Unknown Author',
      coverUrl:
          imageLinks['thumbnail'] ??
          imageLinks['smallThumbnail'] ??
          'https://i.imgur.com/J5LVHEL.png',
      summary: description,
      genres: categories,
    );
  }

  factory Book.fromNytJson(Map<String, dynamic> json) {
    String findIsbn() {
      if (json['primary_isbn13'] != null && json['primary_isbn13'] != '')
        return json['primary_isbn13'];
      if (json['primary_isbn10'] != null && json['primary_isbn10'] != '')
        return json['primary_isbn10'];
      return '${json['title']}_${json['author']}_${DateTime.now().millisecondsSinceEpoch}'
          .hashCode
          .toString();
    }

    return Book(
      id: findIsbn(),
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown Author',
      coverUrl: json['book_image'] ?? 'https://i.imgur.com/J5LVHEL.png',
      summary: json['description'] ?? 'No summary available.',
      genres: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.contains('_') ? id : null,
      'primary_isbn13': !id.contains('_') ? id : null,
      'volumeInfo': {
        'title': title,
        'authors': [author],
        'description': summary,
        'categories': genres,
        'imageLinks': {'thumbnail': coverUrl},
      },
      'title': title,
      'author': author,
      'book_image': coverUrl,
      'description': summary,
    };
  }
}
