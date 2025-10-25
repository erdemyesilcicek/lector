// lib/core/models/book_model.dart

class Book {
  final String id; // Google ID veya NYT ISBN
  final String title;
  final String author;
  final String coverUrl;
  final String summary;
  final List<String> genres; // NYT bunu genellikle vermez

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.summary,
    required this.genres,
  });

  // Google Books API için Factory Constructor
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    final description = volumeInfo['description'] ?? 'No summary available.';
    final categories = (volumeInfo['categories'] as List<dynamic>?)
        ?.map((e) => e.toString())?.toList() ?? [];

    return Book(
      id: json['id'] ?? 'Unknown ID_${DateTime.now().millisecondsSinceEpoch}', // Google ID + fallback
      title: volumeInfo['title'] ?? 'No Title',
      author: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author', // Birden fazla yazar olabilir
      coverUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? 'https://i.imgur.com/J5LVHEL.png', // Fallback ekledik
      summary: description,
      genres: categories,
    );
  }

  // --- YENİ: NYT API için Factory Constructor ---
  factory Book.fromNytJson(Map<String, dynamic> json) {
    // NYT API'si ISBN'leri bazen farklı alanlarda verebilir
    String findIsbn() {
      if (json['primary_isbn13'] != null && json['primary_isbn13'] != '') return json['primary_isbn13'];
      if (json['primary_isbn10'] != null && json['primary_isbn10'] != '') return json['primary_isbn10'];
      // ISBN yoksa benzersiz bir ID üretelim (örn: başlık+yazar hash)
      return '${json['title']}_${json['author']}_${DateTime.now().millisecondsSinceEpoch}'.hashCode.toString();
    }

    return Book(
      id: findIsbn(), // ISBN veya fallback ID
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown Author',
      // NYT'de kapak resmi 'book_image' alanında gelir
      coverUrl: json['book_image'] ?? 'https://i.imgur.com/J5LVHEL.png',
      // NYT'de özet 'description' alanında gelir
      summary: json['description'] ?? 'No summary available.',
      // NYT bu endpoint'te tür bilgisi vermez, boş liste atıyoruz
      genres: [],
    );
  }

  // toJson metodu (Özellikle Book of the Day cache için)
  // Google formatına benzer tutmakta fayda var
  Map<String, dynamic> toJson() {
    return {
      'id': id.contains('_') ? id : null, // Fallback ID ise 'id' kullan
      'primary_isbn13': !id.contains('_') ? id : null, // ISBN ise 'primary_isbn13' kullan
      'volumeInfo': { // Google formatını taklit et
        'title': title,
        'authors': [author], // Liste olarak kaydet
        'description': summary,
        'categories': genres,
        'imageLinks': {'thumbnail': coverUrl},
      },
       // NYT formatını da ekleyelim ki cache'den okurken sorun olmasın
      'title': title,
      'author': author,
      'book_image': coverUrl,
      'description': summary,
    };
  }
}