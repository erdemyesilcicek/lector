// lib/features/onboarding/onboarding_gate.dart

import 'package:flutter/material.dart';
import 'package:lector/features/authentication/auth_gate.dart';
import 'package:lector/features/onboard/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _hasSeenOnboarding; // Null olabilir, başlangıç durumu

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus(); // Durumu kontrol et
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // hasSeenOnboarding anahtarını oku, yoksa false kabul et
    final bool seen = prefs.getBool('hasSeenOnboarding') ?? false;
    // State'i güncelle ve ekranın yeniden çizilmesini sağla
    setState(() {
      _hasSeenOnboarding = seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Durum henüz yüklenmediyse bir yükleme göstergesi göster
    if (_hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Duruma göre yönlendir
    return _hasSeenOnboarding!
        ? const AuthGate() // Onboarding görüldüyse AuthGate'e git
        : const OnboardingScreen(); // Görülmediyse OnboardingScreen'i göster
  }
}