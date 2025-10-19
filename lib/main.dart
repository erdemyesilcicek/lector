// lib/main.dart

import 'package:flutter/material.dart';
import 'package:lector/features/navigation_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lector/features/authentication/auth_gate.dart';
import 'package:lector/core/constants/app_theme.dart';

// main fonksiyonunu async olarak güncelledik
void main() async {
  // Flutter'ın hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LectorApp());
}

class LectorApp extends StatelessWidget {
  const LectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}