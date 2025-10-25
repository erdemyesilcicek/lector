// lib/features/navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/features/explore/explore_screen.dart';
import 'package:lector/features/home/home_screen.dart';
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
    HomeScreen(),
    ExhibitionScreen(),
    ExploreScreen(),
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
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      height: 65 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            selectedIcon: Icons.home,
            index: 0,
            label: 'Home',
          ),
          _buildNavItem(
            icon: Icons.book_outlined,
            selectedIcon: Icons.book,
            index: 1,
            label: 'Exhibition',
          ),
          _buildNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            index: 2,
            label: 'Explore',
          ),
          _buildNavItem(
            icon: Icons.bookmark_outline,
            selectedIcon: Icons.bookmark,
            index: 3,
            label: 'Reading List',
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            index: 4,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? AppColors.accent : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: AppConstants.iconSizeMedium,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
