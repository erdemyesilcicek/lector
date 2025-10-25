// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/providers/theme_provider.dart';
import 'package:lector/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          SwitchListTile.adaptive(
            title: Text(
              'Dark Mode',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          const Divider(),
          // TODO: AYARLAR, Bildirim ayarları, Hesap ayarları vb.
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              'About Lector',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              // TODO: Hakkında sayfası veya popup'ı göster
            },
          ),
        ],
      ),
    );
  }
}
