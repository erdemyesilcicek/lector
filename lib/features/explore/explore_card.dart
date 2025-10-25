// lib/widgets/explore_card.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';

class ExploreCard extends StatelessWidget {
  final String iconAssetPath;
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const ExploreCard({
    super.key,
    required this.iconAssetPath,
    required this.text,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        color: backgroundColor ?? AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.paddingSmall,
                  ),
                  child: Image.asset(
                    iconAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.category_outlined,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.7,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                text,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
