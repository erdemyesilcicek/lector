// lib/core/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/book_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  // Add a book to the user's reading list
  Future<void> addBookToReadingList(Book book) async {
    if (_userId == null) return; // Exit if no user is logged in

    // Structure: users -> {userId} -> reading_list -> {bookId}
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('reading_list')
        .doc(book.id);

    await docRef.set({
      'title': book.title,
      'author': book.author,
      'coverUrl': book.coverUrl,
      'summary': book.summary,
      'genres': book.genres,
      'addedAt': Timestamp.now(),
    });
  }

  // Add a book to the user's exhibition (read books)
  Future<void> addBookToExhibition(Book book, int rating, String notes) async {
    if (_userId == null) return;

    // Structure: users -> {userId} -> exhibition -> {bookId}
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .doc(book.id);

    await docRef.set({
      'title': book.title,
      'author': book.author,
      'coverUrl': book.coverUrl,
      'summary': book.summary,
      'genres': book.genres, // EKLENDİ
      'addedAt': Timestamp.now(),
      'rating': rating,
      'notes': notes,
    });
  }

  // Get a live stream of the user's reading list
  Stream<List<Book>> getReadingListStream() {
    if (_userId == null) {
      return Stream.value([]); // Return an empty stream if no user
    }

    final collectionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('reading_list')
        .orderBy('addedAt', descending: true); // Show newest first

    // Listen to changes in the collection
    return collectionRef.snapshots().map((snapshot) {
      // For each document, convert it to a Book object
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Book(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          author: data['author'] ?? 'No Author',
          coverUrl: data['coverUrl'] ?? '',
          summary: data['summary'] ?? 'No summary available.',
          genres:
              (data['genres'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );
      }).toList();
    });
  }

  // Get a live stream of the user's exhibition
  Stream<List<ExhibitionBook>> getExhibitionStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    final collectionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .orderBy('addedAt', descending: true);

    return collectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Use our new model's factory constructor
        return ExhibitionBook.fromDoc(doc.data(), doc.id);
      }).toList();
    });
  }

  // Delete a book from the user's reading list
  Future<void> deleteFromReadingList(String bookId) async {
    if (_userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('reading_list')
        .doc(bookId);

    await docRef.delete();
  }

  // Delete a book from the user's exhibition
  Future<void> deleteFromExhibition(String bookId) async {
    if (_userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .doc(bookId);

    await docRef.delete();
  }

  // Get the user's exhibition list once
  Future<List<ExhibitionBook>> getExhibitionBooks() async {
    if (_userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .get();

    return snapshot.docs.map((doc) {
      return ExhibitionBook.fromDoc(doc.data(), doc.id);
    }).toList();
  }

  // lib/core/services/database_service.dart dosyasının içine

  Future<List<Book>> getRecommendations() async {
    // 1. ANALİZ: Kullanıcının tüm sergisini al
    final exhibition = await getExhibitionBooks();
    if (exhibition.length < 3) return [];

    // 2. PUANLAMA: Türler ve yazarlar için lezzet puanları oluştur
    final genreScores = <String, int>{};
    final authorScores = <String, int>{};

    for (var book in exhibition) {
      int score = 0;
      if (book.rating == 5) score = 3;
      if (book.rating == 4) score = 2;
      if (book.rating == 3) score = 1;
      if (book.rating <= 2) score = -2;

      for (var genre in book.genres) {
        genreScores[genre] = (genreScores[genre] ?? 0) + score;
      }
      authorScores[book.author] = (authorScores[book.author] ?? 0) + score;
    }

    // 3. PROFİL ÇIKARMA: En yüksek puanlıları bul
    var sortedGenres = genreScores.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var sortedAuthors = authorScores.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedGenres.isEmpty) return [];

    // 4. "DENGELİ PORTFÖY" SORGULARI OLUŞTURMA
    final bookService = BookService();
    final topGenre = sortedGenres.first.key;
    final topAuthor = sortedAuthors.isNotEmpty ? sortedAuthors.first.key : null;

    // Sorgu 1: En sevdiği türde, farklı yazarlardan yeni kitaplar
    final genreSearchFuture = bookService.searchBooks(
      'subject:"$topGenre"&orderBy=newest',
    );

    // Sorgu 2: En sevdiği yazarın, farklı kitapları (eğer varsa)
    final authorSearchFuture = topAuthor != null
        ? bookService.searchBooks('inauthor:"$topAuthor"&orderBy=newest')
        : Future.value([]); // Yazar yoksa boş bir future

    // İki sorguyu aynı anda çalıştırarak zaman kazan
    final results = await Future.wait([genreSearchFuture, authorSearchFuture]);
    final genreResultsJson = results[0];
    final authorResultsJson = results[1];

    // 5. SONUÇLARI BİRLEŞTİR, FİLTRELE VE ÇEŞİTLENDİR
    final allReadBookIds = exhibition.map((b) => b.id).toSet();
    final readingList = await getReadingListStream().first;
    final readingListIds = readingList.map((b) => b.id).toSet();

    // Sonuçları Book nesnelerine çevir ve okunmuş/listede olanları filtrele
    final filter = (List<dynamic> jsonList) {
      return jsonList.map((json) => Book.fromJson(json)).where((book) {
        final hasRead = allReadBookIds.contains(book.id);
        final isOnList = readingListIds.contains(book.id);
        return !hasRead && !isOnList;
      });
    };

    final genreRecommendations = filter(genreResultsJson);
    final authorRecommendations = filter(authorResultsJson);

    // Tekrarları önlemek için bir Map kullanarak iki listeyi birleştir
    final uniqueRecommendations = <String, Book>{};
    for (var book in genreRecommendations) {
      uniqueRecommendations[book.id] = book;
    }
    for (var book in authorRecommendations) {
      uniqueRecommendations[book.id] = book;
    }

    // Son listeyi karıştırarak çeşitliliği artır
    final finalRecommendations = uniqueRecommendations.values.toList()
      ..shuffle();

    return finalRecommendations;
  }

  // Check if a specific book is in the reading list (live)
  Stream<bool> isBookInReadingList(String bookId) {
    if (_userId == null) return Stream.value(false);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('reading_list')
        .doc(bookId)
        .snapshots()
        .map((snapshot) => snapshot.exists); // Returns true if the doc exists
  }

  // Check if a specific book is in the exhibition (live)
  Stream<bool> isBookInExhibition(String bookId) {
    if (_userId == null) return Stream.value(false);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .doc(bookId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Get a live stream of a specific book in the user's exhibition
  Stream<ExhibitionBook?> getExhibitionBookStream(String bookId) {
    if (_userId == null) return Stream.value(null);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .doc(bookId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return ExhibitionBook.fromDoc(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }

  // Get a set of all book IDs in the user's exhibition for quick lookups
  Future<Set<String>> getReadBookIds() async {
    if (_userId == null) return {};

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .get();

    // Return a Set for efficient .contains() checks
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  // Update the rating and notes of a book in the user's exhibition
  Future<void> updateExhibitionBook(
    String bookId,
    int newRating,
    String newNotes,
  ) async {
    if (_userId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .doc(bookId);

    await docRef.update({'rating': newRating, 'notes': newNotes});
  }

  // Get the 3 most recently added books from the user's exhibition
  Future<List<ExhibitionBook>> getRecentExhibitionBooks({int limit = 3}) async {
    if (_userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('exhibition')
        .orderBy('addedAt', descending: true) // En yeniye göre sırala
        .limit(limit) // Belirtilen sayıda al
        .get();

    return snapshot.docs.map((doc) => ExhibitionBook.fromDoc(doc.data(), doc.id)).toList();
  }
}