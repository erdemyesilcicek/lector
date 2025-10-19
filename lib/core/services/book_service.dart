// lib/core/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Fetch trending books (we'll use a general query like "flutter development" for now)
  // TODO: Replace with a better query for "trending" books
  Future<List<dynamic>> fetchTrendingBooks() async {
    try {
      // The query 'subject:fiction' gets a list of general fiction books
      final response = await http.get(Uri.parse('$_baseUrl?q=subject:fiction&maxResults=10'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The API returns a map, and the books are in the 'items' key
        return data['items'] ?? []; 
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Error fetching trending books: $e');
      return []; // Return an empty list on error
    }
  }

  // lib/core/services/book_service.dart dosyasının içine

  // Search for books using a query
  Future<List<dynamic>> searchBooks(String query) async {
    if (query.isEmpty) {
      return []; // Return empty list if query is empty
    }

    try {
      // Encode the query to handle spaces and special characters
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