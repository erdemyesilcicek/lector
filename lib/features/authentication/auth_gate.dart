// lib/features/authentication/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lector/features/authentication/login_screen.dart';
import 'package:lector/features/navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the user's authentication state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, it means the user is logged in
        if (snapshot.hasData) {
          // Show the main app screen
          return const NavigationScreen();
        } else {
          // Otherwise, show the login screen
          return const LoginScreen();
        }
      },
    );
  }
}