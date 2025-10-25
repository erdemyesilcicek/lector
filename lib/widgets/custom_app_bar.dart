// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      automaticallyImplyLeading: true,
      // Geri butonu her zaman beyaz olacak (koyu arka plan için)
      iconTheme: const IconThemeData(color: Colors.white),
      // TAMAMEN ŞEFFAF ARKA PLAN
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppConstants.paddingMedium,

      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: textTheme.displaySmall
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
