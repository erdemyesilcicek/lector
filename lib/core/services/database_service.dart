// lib/core/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart';

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
      'addedAt': Timestamp.now(), // To know when it was added
    });
  }

  // We will implement the "add to exhibition" method in the next steps
  // when we create the rating screen.

  // lib/core/services/database_service.dart dosyasının içine

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
      'addedAt': Timestamp.now(),
      'rating': rating,
      'notes': notes,
    });
  }

  // lib/core/services/database_service.dart dosyasının içine

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
          id: doc.id, // The document ID is the book's ID
          title: data['title'] ?? 'No Title',
          author: data['author'] ?? 'No Author',
          coverUrl: data['coverUrl'] ?? '',
        );
      }).toList();
    });
  }

  // lib/core/services/database_service.dart dosyasının içine

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
}