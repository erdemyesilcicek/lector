// lib/features/authentication/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lector/features/authentication/login_screen.dart';
import 'package:lector/features/navigation_screen.dart';
import 'package:lector/widgets/shimmer_loading.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading durumu - shimmer göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: ProfileShimmer(),
            ),
          );
        }
        
        // Kullanıcı giriş yapmışsa ana ekrana git
        if (snapshot.hasData) {
          return const NavigationScreen();
        }
        
        // Giriş yapmamışsa login ekranına git
        return const LoginScreen();
      },
    );
  }
}
