// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lector/core/constants/app_theme.dart';
import 'package:lector/core/providers/theme_provider.dart'; // ThemeProvider'ı import et
import 'package:lector/features/authentication/auth_gate.dart';
import 'package:provider/provider.dart'; // Provider'ı import et
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Uygulamayı Provider ile sarmalayarak başlat
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LectorApp(),
    ),
  );
}

class LectorApp extends StatelessWidget {
  const LectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider'ı dinle
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Lector',
      debugShowCheckedModeBanner: false,
      // Aktif temayı ThemeProvider'dan al
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme, // Aydınlık tema tanımı
      darkTheme: AppTheme.darkTheme, // Koyu tema tanımı
      home: const AuthGate(),
    );
  }
}