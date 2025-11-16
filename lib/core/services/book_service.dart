// lib/core/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lector/core/models/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class BookService {
  final String _googleBaseUrl = 'https://www.googleapis.com/books/v1/volumes';
  final String _nytBaseUrl =
      'https://api.nytimes.com/svc/books/v3/lists/current';

  final String _nytApiKey =
      '4WjeL8H2ScOZuAaxaGte4urMyOY3nlz1'; // SENİN ANAHTARIN BURADA

  Future<Book?> _fetchBookByIsbn(String isbn) async {
    try {
      final response = await http.get(
        Uri.parse('$_googleBaseUrl?q=isbn:$isbn'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && (data['items'] as List).isNotEmpty) {
          final bookJson = data['items'][0];
          return Book.fromJson(bookJson);
        } else {
          print("Book not found on Google Books for ISBN: $isbn");
          return null;
        }
      } else {
        print(
          'Google API Error (ISBN $isbn): Status Code ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching book by ISBN $isbn: $e');
      return null;
    }
  }

  Future<Book?> fetchBookOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString('book_of_the_day_date');
    final storedBookJsonString = prefs.getString('book_of_the_day_data');

    if (storedDate == today && storedBookJsonString != null) {
      try {
        final bookJson = json.decode(storedBookJsonString);
        return Book.fromNytJson(bookJson);
      } catch (e) {
        print("Error reading Book of the Day from cache: $e");
        await prefs.remove('book_of_the_day_date');
        await prefs.remove('book_of_the_day_data');
      }
    }
    Future<List<Book>> fetchAwardWinners() async {
      List<Book> awardWinningBooks = [];
      try {
        final String jsonString = await rootBundle.loadString(
          'assets/data/award_winners.json',
        );
        final List<dynamic> awardList = json.decode(jsonString);

        List<Future<Book?>> fetchFutures = [];
        for (var entry in awardList) {
          if (entry['isbn'] != null) {
            fetchFutures.add(_fetchBookByIsbn(entry['isbn']));
          }
        }

        final List<Book?> fetchedBooks = await Future.wait(fetchFutures);

        awardWinningBooks = fetchedBooks.whereType<Book>().toList();

        print(
          "Fetched ${awardWinningBooks.length} award winning book details.",
        );
        return awardWinningBooks;
      } catch (e) {
        print('Error fetching award winners: $e');
        return [];
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
      await prefs.setString('book_of_the_day_data', json.encode(bookJson));

      return newBook;
    } catch (e) {
      print('Error fetching Book of the Day from API: $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchRealNytBestsellersJson() async {
    print(">>> NYT API Key Check: Value is '$_nytApiKey'");

    if (_nytApiKey == 'YOUR_NYT_API_KEY_HERE' || _nytApiKey.isEmpty) {
      print(
        "ERROR: NYT API Key is missing or invalid in BookService. Please replace 'YOUR_NYT_API_KEY_HERE' with your actual key.",
      );
      return [];
    }

    const String listName = 'hardcover-fiction';
    final String url = '$_nytBaseUrl/$listName.json?api-key=$_nytApiKey';
    print("Fetching NYT Bestsellers from: $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? books = data['results']?['books'];
        print(
          "NYT API Success: Found ${books?.length ?? 0} books for '$listName'.",
        );
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

  Future<List<Book>> fetchAwardWinners() async {
    List<Book> awardWinningBooks = [];
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/award_winners.json',
      );
      final List<dynamic> awardList = json.decode(jsonString);

      List<Future<Book?>> fetchFutures = [];
      for (var entry in awardList) {
        if (entry['isbn'] != null) {
          fetchFutures.add(_fetchBookByIsbn(entry['isbn']));
        }
      }

      final List<Book?> fetchedBooks = await Future.wait(fetchFutures);
      awardWinningBooks = fetchedBooks.whereType<Book>().toList();

      print("Fetched ${awardWinningBooks.length} award winning book details.");

      print(
        ">>> fetchAwardWinners: Found ${fetchedBooks.length} potential books from ISBNs.",
      );
      print(
        ">>> fetchAwardWinners: Filtered down to ${awardWinningBooks.length} valid Book objects BEFORE HomeScreen filtering.",
      );
      return awardWinningBooks;
    } catch (e) {
      print('Error fetching award winners: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchNewAndNotable() async {
    try {
      final response = await http.get(
        Uri.parse('$_googleBaseUrl?q=*&orderBy=newest&maxResults=15'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        print('Google API Error (New): Status Code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching new books: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchClassicBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$_googleBaseUrl?q=subject:Classics&maxResults=10'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        print(
          'Google API Error (Classics): Status Code ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching classics: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchBooksByGenre(String genre) async {
    try {
      // Popüler ve yeni yayınlanan kitapları getir
      final encodedGenre = Uri.encodeComponent(genre);
      
      // Önce bestseller ve popüler kitapları dene
      final response = await http.get(
        Uri.parse(
          '$_googleBaseUrl?q=subject:$encodedGenre&orderBy=relevance&maxResults=20&langRestrict=en&printType=books',
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> items = data['items'] ?? [];
        
        // Kaliteli kitapları filtrele: kapak resmi ve yeterli bilgiye sahip olanlar
        items = items.where((item) {
          final volumeInfo = item['volumeInfo'];
          if (volumeInfo == null) return false;
          
          // Kapak resmi kontrolü
          final hasImage = volumeInfo['imageLinks']?['thumbnail'] != null;
          
          // Yazar bilgisi kontrolü
          final hasAuthor = volumeInfo['authors'] != null && 
                           (volumeInfo['authors'] as List).isNotEmpty;
          
          // Yayın tarihi kontrolü (2000 sonrası tercih et)
          final publishedDate = volumeInfo['publishedDate']?.toString() ?? '';
          final isRecent = publishedDate.isEmpty || 
                          publishedDate.startsWith(RegExp(r'20[0-9][0-9]|201[0-9]|202[0-9]'));
          
          // Sayfa sayısı kontrolü (çok kısa kitapları eleme)
          final pageCount = volumeInfo['pageCount'] ?? 0;
          final hasReasonableLength = pageCount == 0 || pageCount > 100;
          
          return hasImage && hasAuthor && isRecent && hasReasonableLength;
        }).take(12).toList(); // İlk 12 kaliteli kitabı al
        
        print('Fetched ${items.length} quality books for genre: $genre');
        return items;
      } else {
        print(
          'Google API Error (Genre: $genre): Status Code ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching genre $genre: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchBooks(String query) async {
    if (query.isEmpty) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query);

      // ÇOK GENİŞ ARAMA: Dil kısıtlaması yok, daha fazla sonuç
      final String url = '$_googleBaseUrl?q=$encodedQuery&printType=books&maxResults=40&orderBy=relevance';
      print("Performing wide search with URL: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> items = data['items'] ?? [];

        // Arama terimi ile esnek filtreleme - kelime kelime arama da yapalım
        final lowerQuery = query.toLowerCase();
        final queryWords = lowerQuery.split(' ').where((w) => w.length > 2).toList();
        
        items = items.where((item) {
          final volumeInfo = item['volumeInfo'];
          if (volumeInfo == null) return false;
          
          final title = (volumeInfo['title'] ?? '').toLowerCase();
          final authors = (volumeInfo['authors'] as List<dynamic>?)?.join(', ').toLowerCase() ?? '';
          final searchText = '$title $authors';
          
          // Tam arama terimi geçiyorsa VEYA kelimelerden herhangi biri geçiyorsa kabul et
          if (searchText.contains(lowerQuery)) return true;
          
          // Kelime kelime kontrol - en az bir kelime geçmeli
          for (var word in queryWords) {
            if (searchText.contains(word)) return true;
          }
          
          return false;
        }).toList();

        // --- UYGULAMA İÇİ TEKİLLEŞTİRME ---
        if (items.isNotEmpty) {
          final uniqueBooks = <String, Map<String, dynamic>>{};
          final seenKeys = <String>{};

          for (var item in items) {
            final volumeInfo = item['volumeInfo'];
            if (volumeInfo == null) continue;

            final title = (volumeInfo['title'] ?? '').toLowerCase();
            final authors = (volumeInfo['authors'] as List<dynamic>?)?.join(', ').toLowerCase() ?? '';
            final bookKey = '$title###${authors.split(',').first.trim()}';

            if (!seenKeys.contains(bookKey) ||
                (volumeInfo['imageLinks']?['thumbnail'] != null && 
                 uniqueBooks[bookKey]?['volumeInfo']?['imageLinks']?['thumbnail'] == null))
            {
              seenKeys.add(bookKey);
              uniqueBooks[bookKey] = item as Map<String, dynamic>;
            }
          }
          items = uniqueBooks.values.toList();
          print("Search complete. Returning ${items.length} unique results for query: $query");
        }
        return items;

      } else {
         print('Google API Error (Search: $query): Status Code ${response.statusCode}');
         return [];
      }
    } catch (e) {
      print('Error during book search: $e');
      return [];
    }
  }

  Future<List<Book>> fetchDiscoveryDeckBooks({int count = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_googleBaseUrl?q=subject:fiction&orderBy=relevance&maxResults=$count',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        print('Google API Error (Deck): Status Code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching discovery deck books: $e');
      return [];
    }
  }
}
