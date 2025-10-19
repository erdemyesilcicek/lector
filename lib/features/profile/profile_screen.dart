// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/services/auth_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/profile/recommendations_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _calculateStats();
  }

  // --- GÜNCELLENEN METOT ---
  // Artık favori tür ve yazarı da hesaplıyor
  Future<Map<String, dynamic>> _calculateStats() async {
    final books = await _databaseService.getExhibitionBooks();

    if (books.isEmpty) {
      return {
        'totalBooks': 0,
        'favoriteGenre': 'N/A',
        'favoriteAuthor': 'N/A',
      };
    }

    // --- FAVORİ TÜR HESAPLAMASI ---
    final genreCounts = <String, int>{};
    for (var book in books) {
      // Sadece 4 ve 5 yıldızlı kitapların türlerini dikkate al
      if (book.rating >= 4) {
        for (var genre in book.genres) {
          genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
        }
      }
    }
    String favoriteGenre = 'N/A';
    if (genreCounts.isNotEmpty) {
      // En çok tekrar eden anahtarı (türü) bul
      favoriteGenre =
          genreCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // --- FAVORİ YAZAR HESAPLAMASI ---
    final authorCounts = <String, int>{};
    for (var book in books) {
      authorCounts[book.author] = (authorCounts[book.author] ?? 0) + 1;
    }
    String favoriteAuthor = 'N/A';
    if (authorCounts.isNotEmpty) {
      // En çok tekrar eden anahtarı (yazarı) bul
      favoriteAuthor =
          authorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return {
      'totalBooks': books.length,
      'favoriteGenre': favoriteGenre,
      'favoriteAuthor': favoriteAuthor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load stats.'));
          }

          final stats = snapshot.data ??
              {
                'totalBooks': 0,
                'favoriteGenre': 'N/A',
                'favoriteAuthor': 'N/A'
              };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- STATS CARD ---
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    // --- GÜNCELLENEN KISIM ---
                    child: Column(
                      children: [
                        const Text(
                          'Reading Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(), // Ayırıcı
                        const SizedBox(height: 10),
                        _buildStatRow(
                          'Total Books Read',
                          '${stats['totalBooks']}',
                        ),
                        _buildStatRow(
                          'Favorite Genre',
                          stats['favoriteGenre'],
                        ),
                        _buildStatRow(
                          'Favorite Author',
                          stats['favoriteAuthor'],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- SMART RECOMMENDATIONS BUTTON ---
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Get Smart Recommendations'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

                const Spacer(),

                // --- SIGN OUT BUTTON ---
                TextButton.icon(
                  onPressed: () {
                    _authService.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}