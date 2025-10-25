// lib/features/profile/profile_screen.dart

import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth'ı import et
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/models/book_model.dart'; // Book modelini import et
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/auth_service.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/explore/book_detail_screen.dart'; // Detay ekranı için
import 'package:lector/features/profile/recommendations_screen.dart';
import 'package:lector/widgets/banner_card.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/generated_cover_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final User? _currentUser =
      FirebaseAuth.instance.currentUser; // Mevcut kullanıcıyı al

  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final books = await _databaseService.getExhibitionBooks();
    final recentBooks = await _databaseService.getRecentExhibitionBooks(
      limit: 3,
    );

    Map<String, dynamic> stats = {
      'totalBooks': 0,
      'favoriteGenre': 'N/A',
      'favoriteAuthor': 'N/A',
    };

    if (books.isNotEmpty) {
      // Favori Tür Hesaplaması
      final genreCounts = <String, int>{};
      for (var book in books) {
        if (book.rating >= 4) {
          for (var genre in book.genres) {
            genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
          }
        }
      }
      String favoriteGenre = 'N/A';
      if (genreCounts.isNotEmpty) {
        favoriteGenre = genreCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      // Favori Yazar Hesaplaması
      final authorCounts = <String, int>{};
      for (var book in books) {
        authorCounts[book.author] = (authorCounts[book.author] ?? 0) + 1;
      }
      String favoriteAuthor = 'N/A';
      if (authorCounts.isNotEmpty) {
        favoriteAuthor = authorCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      stats = {
        'totalBooks': books.length,
        'favoriteGenre': favoriteGenre,
        'favoriteAuthor': favoriteAuthor,
      };
    }

    return {'stats': stats, 'recentBooks': recentBooks};
  }

  String _getInitials(String? email) {
    if (email == null || email.isEmpty) return '?';

    final username = email.split('@').first;
    if (username.isEmpty) return '?';

    // İlk harfi al ve büyük yap
    return username[0].toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'No Email';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email; // Çok kısaysa maskeleme
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Profile'),
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(
              "Profile Load Error: ${snapshot.error}",
            ); // Hata ayıklama için
            return const Center(child: Text('Could not load profile data.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available.'));
          }

          final profileData = snapshot.data!;
          final stats = profileData['stats'] as Map<String, dynamic>;
          final recentBooks =
              profileData['recentBooks'] as List<ExhibitionBook>;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _profileDataFuture = _loadProfileData();
              });
            },
            child: ListView(
              // Column yerine ListView, uzun içerik için
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.6),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                _getInitials(_currentUser?.email),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.paddingLarge),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.sunny,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getGreeting(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _maskEmail(_currentUser?.email),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Profil ayarlarına git
                        },
                        icon: Icon(
                          Icons.settings_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // --- YENİDEN TASARLANMIŞ İSTATİSTİK KARTI ---
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surface,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.auto_graph_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              Text(
                                'Reading Stats',
                                style: AppTextStyles.headline3.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingLarge),
                          _buildModernStatRow(
                            Icons.book_rounded,
                            'Total Books Read',
                            '${stats['totalBooks']}',
                            Colors.teal,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          _buildModernStatRow(
                            Icons.favorite_rounded,
                            'Favorite Genre',
                            stats['favoriteGenre'],
                            Colors.pink,
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          _buildModernStatRow(
                            Icons.edit_rounded,
                            'Favorite Author',
                            stats['favoriteAuthor'],
                            Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // --- AKILLI ÖNERİLER BUTONU ---
                BannerCard(
                  title: "Recommendation",
                  description: "Discover books you’ll love.",
                  assetImagePath: "assets/icon/images/light.png",
                  height: 100,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendationsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // --- SON EKLENENLER BÖLÜMÜ ---
                if (recentBooks.isNotEmpty) ...[
                  Text('Recently Added', style: AppTextStyles.headline3),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    height: 180, // Bu bölümün yüksekliği
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentBooks.length,
                      itemBuilder: (context, index) {
                        final book = recentBooks[index];
                        // BookCard'ı burada da kullanabiliriz
                        return SizedBox(
                          width: 120, // Daha küçük genişlik
                          child: _buildRecentBookCard(book),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // --- ÇIKIŞ YAP BUTONU ---
                Center(
                  // Ortalamak için
                  child: TextButton.icon(
                    onPressed: () {
                      _authService.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernStatRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Son eklenen kitaplar için özel, daha küçük kart
  Widget _buildRecentBookCard(ExhibitionBook exBook) {
    final bookForDetail = Book(
      id: exBook.id,
      title: exBook.title,
      author: exBook.author,
      coverUrl: exBook.coverUrl,
      summary: exBook.summary,
      genres: exBook.genres,
    );
    final bool hasRealCover = !exBook.coverUrl.contains(
      'i.imgur.com/J5LVHEL.png',
    );

    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: bookForDetail),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: hasRealCover
              ? Image.network(
                  exBook.coverUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return GeneratedCover(
                      title: exBook.title,
                      author: exBook.author,
                    );
                  },
                )
              : GeneratedCover(title: exBook.title, author: exBook.author),
        ),
      ),
    );
  }
}
