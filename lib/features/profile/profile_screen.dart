// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authService.signOut();
            // AuthGate will automatically navigate to the LoginScreen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sign Out'),
        ),
      ),
    );
  }
}