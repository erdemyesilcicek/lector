// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lector/core/constants/app_theme.dart';
import 'package:lector/core/providers/theme_provider.dart';
import 'package:lector/features/authentication/auth_gate.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Status bar'ı siyah yap
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Lector',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}