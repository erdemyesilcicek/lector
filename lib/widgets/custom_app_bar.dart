// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      iconTheme: IconThemeData(color: theme.colorScheme.primary),
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppConstants.paddingMedium,

      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500)),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
