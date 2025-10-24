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

  // Hem istatistikleri hem de son eklenenleri tek seferde yükleyen metot
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

  // E-postayı maskelemek için yardımcı fonksiyon
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
            // Sayfayı yenileme özelliği
            onRefresh: () async {
              setState(() {
                _profileDataFuture = _loadProfileData();
              });
            },
            child: ListView(
              // Column yerine ListView, uzun içerik için
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              children: [
                // --- KULLANICI BİLGİSİ ---
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.surface,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.textSecondary,
                      ),
                      // TODO: Gelecekte profil resmi eklenebilir
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _maskEmail(_currentUser?.email),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // --- YENİDEN TASARLANMIŞ İSTATİSTİK KARTI ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reading Stats', style: AppTextStyles.headline3),
                        const SizedBox(height: AppConstants.paddingSmall),
                        const Divider(color: AppColors.textSecondary),
                        _buildStatRow(
                          Icons.book_outlined,
                          'Total Books Read',
                          '${stats['totalBooks']}',
                        ),
                        _buildStatRow(
                          Icons.favorite_border,
                          'Favorite Genre',
                          stats['favoriteGenre'],
                        ),
                        _buildStatRow(
                          Icons.edit_outlined,
                          'Favorite Author',
                          stats['favoriteAuthor'],
                        ),
                      ],
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

  // İstatistik satırı için ikonlu yeni yardımcı widget
  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppConstants.paddingMedium),
          Text(title, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
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
