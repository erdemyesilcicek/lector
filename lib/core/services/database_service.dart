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
      'genres': book.genres, // EKLENDİ
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

  // Get book recommendations based on user's exhibition
  Future<List<Book>> getRecommendations() async {
    // 1. Kullanıcının okuduğu ve yüksek puan verdiği kitapları al
    final exhibition = await getExhibitionBooks();
    if (exhibition.isEmpty) return [];

    // 4 veya 5 yıldız verilmiş kitapları filtrele
    final highRatedBooks = exhibition.where((b) => b.rating >= 4).toList();
    if (highRatedBooks.isEmpty) return [];

    // 2. Analiz için bir "tohum" (seed) seç
    // En son eklenen yüksek puanlı kitabın ilk türünü tohum olarak alalım (basit bir başlangıç)
    highRatedBooks.shuffle(); // Biraz rastgelelik katalım
    final seedBook = highRatedBooks.first;
    if (seedBook.genres.isEmpty) return [];
    final seedGenre = seedBook.genres.first;

    // 3. Google Books API'sinde bu türe göre yeni kitaplar ara
    final bookService = BookService(); // BookService'i burada kullanıyoruz
    final searchResultsJson = await bookService.searchBooks(
      'subject:${seedGenre}',
    );

    // 4. Sonuçları filtrele: Kullanıcının zaten okuduğu veya listesine eklediği kitapları çıkar
    final allReadBookIds = exhibition.map((b) => b.id).toSet();
    final readingList = await getReadingListStream().first; // Anlık listeyi al
    final readingListIds = readingList.map((b) => b.id).toSet();

    final recommendations = searchResultsJson
        .map((json) => Book.fromJson(json))
        .where((book) {
          final hasRead = allReadBookIds.contains(book.id);
          final isOnList = readingListIds.contains(book.id);
          return !hasRead &&
              !isOnList; // Henüz okunmamış ve listede olmayanları al
        })
        .toList();

    return recommendations;
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



}
