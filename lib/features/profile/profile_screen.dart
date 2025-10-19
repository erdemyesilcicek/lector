// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/models/exhibition_book_model.dart';
import 'package:lector/core/services/auth_service.dart';
import 'package:lector/core/services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  // A future to hold the statistics data
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _calculateStats();
  }

  // Method to fetch data and calculate stats
  Future<Map<String, dynamic>> _calculateStats() async {
    final books = await _databaseService.getExhibitionBooks();
    
    // Simple calculation for total books read
    final totalBooks = books.length;

    // TODO: Add more complex calculations (favorite genre, etc.)
    
    return {
      'totalBooks': totalBooks,
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

          final stats = snapshot.data ?? {'totalBooks': 0};

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- STATS CARD ---
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Reading Stats',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _buildStatRow('Total Books Read', '${stats['totalBooks']}'),
                        // TODO: Add more stat rows here
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // --- SMART RECOMMENDATIONS BUTTON ---
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to recommendations screen
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Get Smart Recommendations'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                
                // Spacer to push the sign out button to the bottom
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

  // Helper widget for a single statistic row
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