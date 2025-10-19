import 'package:flutter/material.dart';
import 'package:lector/features/navigation_screen.dart';

// Uygulamanın başlangıç noktası
void main() {
  runApp(const LectorApp());
}

// Uygulamanın ana iskeleti
class LectorApp extends StatelessWidget {
  const LectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const NavigationScreen(),
    );
  }
}