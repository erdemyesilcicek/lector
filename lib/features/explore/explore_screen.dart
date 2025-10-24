// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
// Constants ve Modeller
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/models/book_model.dart';
import 'package:lector/core/models/exhibition_book_model.dart'; // Gerekli olabilir
// Servisler
import 'package:lector/core/services/book_service.dart';
import 'package:lector/core/services/database_service.dart';
// Diğer Ekranlar
import 'package:lector/features/explore/book_detail_screen.dart'; // BookDetailScreen importu
import 'package:lector/features/explore/explore_big_card.dart';
import 'package:lector/features/explore/explore_card.dart';
// Widgetlar
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:lector/widgets/rating_modal_widget.dart'; // Mark as Read için

// StatefulWidget'e dönüştürüyoruz çünkü veri çekeceğiz
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Servisleri ve Future'ı tanımla
  final BookService _bookService = BookService();
  final DatabaseService _databaseService = DatabaseService();
  Future<List<Book>>? _fantasyBooksFuture;

  // Filtreleme için ID setleri
  Set<String> _readBookIds = {};
  Set<String> _readingListIds = {};

  @override
  void initState() {
    super.initState();
    // Sayfa açılırken veriyi yükle
    _loadFantasyBooks();
  }

  // Veriyi yükleyen ve filtreleyen metot
  Future<void> _loadFantasyBooks() async {
    // Önce dışlanacak ID'leri al
    _readBookIds = await _databaseService.getReadBookIds();
    final readingList = await _databaseService.getReadingListStream().first;
    _readingListIds = readingList.map((b) => b.id).toSet();
    final excludedIds = _readBookIds.union(_readingListIds);

    // Veriyi çek ve state'i güncelle
    setState(() {
      _fantasyBooksFuture = _fetchGoogleBooksAndFilter(
        () => _bookService.fetchBooksByGenre('fantasy'),
        excludedIds,
      );
    });
  }

  // Google Books API sonuçlarını filtreleyen metot (HomeScreen'dekiyle aynı)
  Future<List<Book>> _fetchGoogleBooksAndFilter(
    Future<List<dynamic>> Function() fetcher,
    Set<String> excludedIds,
  ) async {
    final booksJson = await fetcher();
    return booksJson
        .map((json) => Book.fromJson(json))
        .where((book) => !excludedIds.contains(book.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema'yı alalım

    return Scaffold(
      appBar: const CustomAppBar(title: 'Explore'),
      backgroundColor: theme.scaffoldBackgroundColor,
      // Ana gövdeyi SingleChildScrollView ile sarıyoruz
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Başlıkları sola yasla
          children: [
            // --- ÜST BÖLÜM: Kategori Kartları (GridView) ---
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                'Categories',
                style: theme.textTheme.headlineSmall,
              ), // Bölüm Başlığı
            ),
            GridView.count(
              shrinkWrap: true, // ListView içinde boyutunu küçültmesi için
              physics:
                  const NeverScrollableScrollPhysics(), // GridView kendi başına kaymasın
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              crossAxisCount: 3,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
              childAspectRatio: 0.9,
              children: <Widget>[
                // Senin eklediğin ExploreCard'lar buraya gelecek (içerikleri aynı)
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/sci-fi.png',
                  text: 'Sci-Fi',
                  onTap: () {
                    print('Sci-Fi tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/thriller.png',
                  text: 'Thriller',
                  onTap: () {
                    print('Thriller tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/romance.png',
                  text: 'Romance',
                  onTap: () {
                    print('Romance tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/fantasy.png',
                  text: 'Fantasy',
                  onTap: () {
                    print('Fantasy tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/religion.png',
                  text: 'Religion',
                  onTap: () {
                    print('Religion tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/history.png',
                  text: 'History',
                  onTap: () {
                    print('History tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/detective.png',
                  text: 'Detective',
                  onTap: () {
                    print('Detective tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/science.png',
                  text: 'Science',
                  onTap: () {
                    print('Science tıklandı');
                  },
                ),
                ExploreCard(
                  iconAssetPath: 'assets/icon/images/children.png',
                  text: 'Children',
                  onTap: () {
                    print('Children tıklandı');
                  },
                ),
              ],
            ),

            // --- ALT BÖLÜM: Yatay Kayan Kitap Listesi ---
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                top: AppConstants.paddingLarge, // Üstteki Grid ile araya boşluk
                bottom: AppConstants.paddingSmall, // Liste öncesi boşluk
              ),
              child: Text(
                'Classics',
                style: theme.textTheme.headlineSmall,
              ), // Bölüm Başlığı
            ),
            // FutureBuilder ile yatay listeyi oluştur
            _buildHorizontalBigCardList(_fantasyBooksFuture), // Yeni liste metodu

            const SizedBox(height: AppConstants.paddingLarge), // En alta boşluk
          ],
        ),
      ),
    );
  }

  // ExploreBigCard İçin Yatay Liste Metodu (HomeScreen'den alındı ve uyarlandı)
  Widget _buildHorizontalBigCardList(Future<List<Book>>? future) {
    final theme = Theme.of(context);
    const double cardHeight = 280.0; // BigCard yüksekliği
    const double cardWidth = cardHeight * 0.7; // Genişliği

    // Future null ise veya henüz tamamlanmadıysa yükleme göstergesi
    if (future == null) {
      return const SizedBox(
        height: cardHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<List<Book>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: cardHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: cardHeight,
            child: Center(
              child: Text(
                'Error loading books',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: cardHeight,
            child: Center(
              child: Text(
                'No books found in this category.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final books = snapshot.data!;
        return SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              // Her kart için okuma listesi durumunu dinle
              return StreamBuilder<bool>(
                stream: _databaseService.isBookInReadingList(book.id),
                builder: (context, listSnapshot) {
                  final isInReadingList = listSnapshot.data ?? false;
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(
                      right: AppConstants.paddingMedium,
                    ),
                    child: ExploreBigCard(
                      book: book,
                      isInReadingList: isInReadingList,
                      onMarkAsRead: () async {
                        final result =
                            await showModalBottomSheet<Map<String, dynamic>>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const RatingModal(),
                              isScrollControlled: true,
                            );
                        if (result != null && mounted) {
                          final int rating = result['rating'];
                          final String notes = result['notes'];
                          await _databaseService.addBookToExhibition(
                            book,
                            rating,
                            notes,
                          );
                          if (isInReadingList) {
                            await _databaseService.deleteFromReadingList(
                              book.id,
                            );
                          }
                          setState(() {
                            _readBookIds.add(book.id);
                          }); // Listeyi anında filtrelemek için
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to your Exhibition!'),
                            ),
                          );
                          // Bu ekranda listeyi yeniden yüklemeye gerek yok, ID filtrelemesi yeterli
                        }
                      },
                      onToggleReadingList: () {
                        if (isInReadingList) {
                          _databaseService.deleteFromReadingList(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from your Reading List!'),
                            ),
                          );
                        } else {
                          _databaseService.addBookToReadingList(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to your Reading List!'),
                            ),
                          );
                        }
                        // Anlık state güncellemesi StreamBuilder tarafından yapılır
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
} // Sınıfın sonu
