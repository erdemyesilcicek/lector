// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Başlangıçta aydınlık tema
  static const String _themePrefKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Uygulama başlarken hafızadaki temayı yükle
  }

  // Hafızadan tema tercihini yükle
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePrefKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // Temayı değiştir ve hafızaya kaydet
  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Dinleyen widget'lara haber ver

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePrefKey, _themeMode.index);
  }
}