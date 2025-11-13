// lib/features/profile/profile_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';
import 'package:lector/core/services/database_service.dart';
import 'package:lector/features/profile/recommendations_screen.dart';
import 'package:lector/features/settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late Future<Map<String, dynamic>> _profileDataFuture;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final books = await _databaseService.getExhibitionBooks();
    final userProfile = await _databaseService.getUserProfile();

    // Load profile data
    _displayName = userProfile?['displayName'];

    Map<String, dynamic> stats = {
      'totalBooks': 0,
      'favoriteGenre': 'N/A',
      'favoriteAuthor': 'N/A',
    };

    if (books.isNotEmpty) {
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

    return {'stats': stats};
  }

  String _getInitials(String? email) {
    if (_displayName != null && _displayName!.isNotEmpty) {
      return _displayName!.substring(0, _displayName!.length < 2 ? 1 : 2).toUpperCase();
    }
    if (email == null || email.isEmpty) return '?';
    final username = email.split('@').first;
    if (username.isEmpty) return '?';
    return username.substring(0, username.length < 2 ? 1 : 2).toUpperCase();
  }

  String _getUsername(String? email) {
    if (_displayName != null && _displayName!.isNotEmpty) {
      return _displayName!;
    }
    if (email == null || email.isEmpty) return 'User';
    return email.split('@').first;
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: _displayName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Edit Name', style: AppTextStyles.headline3),
        content: TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(
              'Save',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _databaseService.updateUserProfile(displayName: result);
      setState(() {
        _displayName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load profile data.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available.'));
          }

          final profileData = snapshot.data!;
          final stats = profileData['stats'] as Map<String, dynamic>;

          return CustomScrollView(
            slivers: [
              // Minimal App Bar
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Minimalist Profile Header
                      Center(
                        child: Column(
                          children: [
                            // Simple Circle Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.1),
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(_currentUser?.email),
                                  style: AppTextStyles.headline1.copyWith(
                                    color: AppColors.background,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Username with edit button
                            GestureDetector(
                              onTap: _editDisplayName,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getUsername(_currentUser?.email),
                                    style: AppTextStyles.headline1.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Email
                            Text(
                              _currentUser?.email ?? 'no email',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Stats Section with Minimal Design
                      Row(
                        children: [
                          Expanded(
                            child: _buildMinimalStat(
                              '${stats['totalBooks']}',
                              'Books Read',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.border.withOpacity(0.3),
                      ),

                      const SizedBox(height: 40),

                      // Favorite Details
                      _buildDetailRow('Favorite Genre', stats['favoriteGenre']),

                      const SizedBox(height: 32),

                      _buildDetailRow(
                        'Favorite Author',
                        stats['favoriteAuthor'],
                      ),

                      const SizedBox(height: 50),

                      // Action Buttons
                      _buildActionButton(
                        'Get Recommendations',
                        Icons.auto_awesome_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RecommendationsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMinimalStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline1.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.w200,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 1.5,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 1.2,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppColors.primary
                : AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isPrimary ? AppColors.background : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            Icon(
              icon,
              color: isPrimary ? AppColors.background : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
