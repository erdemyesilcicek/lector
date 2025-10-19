import 'package:flutter/material.dart';

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
      // Sağ üstteki "DEBUG" etiketini kaldırır
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      // Uygulamanın ilk açılacak ekranı (şimdilik boş)
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lector'),
        ),
        body: const Center(
          child: Text('Proje Temizlendi!'),
        ),
      ),
    );
  }
}