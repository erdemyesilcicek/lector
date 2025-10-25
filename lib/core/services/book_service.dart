// lib/core/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lector/core/models/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final String _googleBaseUrl = 'https://www.googleapis.com/books/v1/volumes';
  final String _nytBaseUrl = 'https://api.nytimes.com/svc/books/v3/lists/current';

  // --- API Anahtarın ---
  // API Anahtarını buraya yapıştırdığından emin ol!
  final String _nytApiKey = '4WjeL8H2ScOZuAaxaGte4urMyOY3nlz1'; // SENİN ANAHTARIN BURADA

  // --- Fetch Book of the Day (Using NYT API) ---
  Future<Book?> fetchBookOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString('book_of_the_day_date');
    final storedBookJsonString = prefs.getString('book_of_the_day_data');

    if (storedDate == today && storedBookJsonString != null) {
      print("Fetching Book of the Day from CACHE.");
      try {
        final bookJson = json.decode(storedBookJsonString);
        return Book.fromNytJson(bookJson);
      } catch (e) {
        print("Error reading Book of the Day from cache: $e");
        await prefs.remove('book_of_the_day_date');
        await prefs.remove('book_of_the_day_data');
      }
    }

    print("Fetching Book of the Day from API.");
    try {
      final bestsellersJsonList = await fetchRealNytBestsellersJson();
      if (bestsellersJsonList.isEmpty) return null;

      bestsellersJsonList.shuffle();
      final bookJson = bestsellersJsonList.first;
      final newBook = Book.fromNytJson(bookJson);

      await prefs.setString('book_of_the_day_date', today);
      await prefs.setString('book_of_the_day_data', json.encode(bookJson)); // Ham NYT JSON'ı kaydet

      return newBook;
    } catch (e) {
      print('Error fetching Book of the Day from API: $e');
      return null;
    }
  }

  // --- Fetch REAL NYT Bestsellers List (JSON) ---
  Future<List<dynamic>> fetchRealNytBestsellersJson() async {
    print(">>> NYT API Key Check: Value is '$_nytApiKey'");

    // --- DOĞRU KONTROL BURADA ---
    // Eğer anahtar hala varsayılan metinse veya boşsa hata ver.
    if (_nytApiKey == 'YOUR_NYT_API_KEY_HERE' || _nytApiKey.isEmpty) {
      print("ERROR: NYT API Key is missing or invalid in BookService. Please replace 'YOUR_NYT_API_KEY_HERE' with your actual key.");
      return [];
    }
    // --- ---

    const String listName = 'hardcover-fiction';
    final String url = '$_nytBaseUrl/$listName.json?api-key=$_nytApiKey';
    print("Fetching NYT Bestsellers from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? books = data['results']?['books'];
        print("NYT API Success: Found ${books?.length ?? 0} books for '$listName'.");
        return books ?? [];
      } else {
        print('NYT API Error: Status Code ${response.statusCode}');
        print('NYT API Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error during NYT API call: $e');
      return [];
    }
  }

  // --- Google Books API Methods (Bunlarda değişiklik yok) ---

  Future<List<dynamic>> fetchNewAndNotable() async {
    try {
      final response = await http.get(Uri.parse('$_googleBaseUrl?q=*&orderBy=newest&maxResults=15'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
         print('Google API Error (New): Status Code ${response.statusCode}'); return [];
      }
    } catch (e) { print('Error fetching new books: $e'); return []; }
  }

  Future<List<dynamic>> fetchClassicBooks() async {
     try {
      final response = await http.get(Uri.parse('$_googleBaseUrl?q=subject:Classics&maxResults=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
         print('Google API Error (Classics): Status Code ${response.statusCode}'); return [];
      }
    } catch (e) { print('Error fetching classics: $e'); return []; }
  }

  Future<List<dynamic>> fetchBooksByGenre(String genre) async {
    try {
      final encodedGenre = Uri.encodeComponent(genre);
      final response = await http.get(Uri.parse('$_googleBaseUrl?q=subject:$encodedGenre&maxResults=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
         print('Google API Error (Genre: $genre): Status Code ${response.statusCode}'); return [];
      }
    } catch (e) { print('Error fetching genre $genre: $e'); return []; }
  }

  Future<List<dynamic>> searchBooks(String query) async {
    if (query.isEmpty) return [];
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(Uri.parse('$_googleBaseUrl?q=$encodedQuery&maxResults=20'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
         print('Google API Error (Search: $query): Status Code ${response.statusCode}'); return [];
      }
    } catch (e) { print('Error searching books: $e'); return []; }
  }

   Future<List<Book>> fetchDiscoveryDeckBooks({int count = 20}) async {
     try {
      final response = await http.get(Uri.parse('$_googleBaseUrl?q=subject:fiction&orderBy=relevance&maxResults=$count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
         print('Google API Error (Deck): Status Code ${response.statusCode}'); return [];
      }
    } catch (e) { print('Error fetching discovery deck books: $e'); return []; }
  }
} // Sınıfın Sonu