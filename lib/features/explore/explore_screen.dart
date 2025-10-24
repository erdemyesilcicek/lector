// lib/features/explore/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/widgets/custom_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Explore'),
      body: Center(
        child: Text(
          'Explore Screen - Coming Soon!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}