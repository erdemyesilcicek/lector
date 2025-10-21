// lib/features/navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart'; // Import AppColors
import 'package:lector/core/constants/app_constants.dart'; // Import AppConstants
import 'package:lector/features/explore/explore_screen.dart';
import 'package:lector/features/profile/profile_screen.dart';
import 'package:lector/features/reading_list/reading_list_screen.dart';
import 'package:lector/features/exhibition/exhibition_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    ExploreScreen(),
    ExhibitionScreen(),
    ReadingListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      // Use backgroundColor from AppColors for consistency
      backgroundColor: AppColors.background, 
      // Replace BottomNavigationBar with our custom navigation bar
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  // --- NEW: Custom Navigation Bar Widget ---
  Widget _buildCustomNavigationBar() {
    return Container(
      height: 65 + MediaQuery.of(context).padding.bottom, // Standard height + safe area
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom), // Handle bottom safe area
      decoration: const BoxDecoration(
        color: AppColors.surface, // Use surface color from our theme
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2), // Shadow pointing upwards
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore, index: 0, label: 'Explore'),
          _buildNavItem(icon: Icons.book_outlined, selectedIcon: Icons.book, index: 1, label: 'Exhibition'),
          _buildNavItem(icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark, index: 2, label: 'Reading List'),
          _buildNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, index: 3, label: 'Profile'),
        ],
      ),
    );
  }

  // --- NEW: Helper Widget for Each Navigation Item ---
  Widget _buildNavItem({required IconData icon, required IconData selectedIcon, required int index, required String label}) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.accent : AppColors.textSecondary;

    return Expanded( // Ensure items share space equally
      child: GestureDetector( // Use GestureDetector to avoid ripple
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque, // Makes the entire Expanded area tappable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: AppConstants.iconSizeMedium,
            ),
            const SizedBox(height: 4), // Space between icon and label
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10, // Slightly smaller label
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}