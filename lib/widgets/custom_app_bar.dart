// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // Sağ tarafa ikon/buton eklemek için opsiyonel liste

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Geri butonunun otomatik olarak görünmesini sağlar
      automaticallyImplyLeading: true, 
      // Geri butonu ikon rengini tasarım sistemimizden alır
      iconTheme: const IconThemeData(color: AppColors.primary),
      backgroundColor: AppColors.background,
      elevation: 0,
      // Başlığın soldan başlaması için boşluğu sıfırlıyoruz
      titleSpacing: AppConstants.paddingMedium, 
      
      // Başlığı sola yaslıyoruz
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.headline2,
        ),
      ),
      actions: actions,
    );
  }

  // AppBar'ın standart yüksekliğini belirtiyoruz.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}