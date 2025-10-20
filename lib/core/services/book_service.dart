// lib/core/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // "Trending" yerine artık "En Yeni ve Dikkate Değer" kitapları çekiyoruz
  Future<List<dynamic>> fetchNewAndNotable() async {
    try {
      // YENİ VE AKILLI YAKLAŞIM: İçinde bulunduğumuz yılı dinamik olarak al
      final currentYear = DateTime.now().year;

      // Sorguyu, içinde bu yılın geçtiği kitapları arayacak şekilde güncelliyoruz.
      // Bu, bize gerçekten yeni çıkmış kitapları bulma olasılığını çok artırır.
      final response = await http.get(Uri.parse('$_baseUrl?q=inpublisher:$currentYear&maxResults=15'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to load new books');
      }
    } catch (e) {
      print('Error fetching new books: $e');
      return [];
    }
  }

  // Fetch New York Times bestsellers
  Future<List<dynamic>> fetchNytBestsellers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q="new york times best sellers"&maxResults=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to load bestsellers');
      }
    } catch (e) {
      print('Error fetching bestsellers: $e');
      return [];
    }
  }

  // Fetch books by a specific genre
  Future<List<dynamic>> fetchBooksByGenre(String genre) async {
    try {
      final encodedGenre = Uri.encodeComponent(genre);
      final response = await http.get(Uri.parse('$_baseUrl?q=subject:$encodedGenre&maxResults=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to load genre: $genre');
      }
    } catch (e) {
      print('Error fetching genre $genre: $e');
      return [];
    }
  }

  // Search for books using a query
  Future<List<dynamic>> searchBooks(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(Uri.parse('$_baseUrl?q=$encodedQuery&maxResults=20'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to search books');
      }
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }
}