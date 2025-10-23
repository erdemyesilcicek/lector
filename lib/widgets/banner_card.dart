// lib/widgets/banner_card.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';

class BannerCard extends StatelessWidget {
  final String title;
  final String description;
  final String? assetImagePath; // Local asset path (PRIORITY)
  final String? imageUrl; // Network URL (Used if asset is null)
  final VoidCallback? onTap;
  final double? height;
  final Color? backgroundColor;

  const BannerCard({
    super.key,
    required this.title,
    required this.description,
    this.assetImagePath,
    this.imageUrl,
    this.onTap,
    this.height,
    this.backgroundColor,
  }) : assert(assetImagePath != null || imageUrl != null,
            'BannerCard requires either assetImagePath or imageUrl.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- Determine the Image Widget ---
    Widget imageWidget;

    // 1. Prioritize Asset Image
    if (assetImagePath != null && assetImagePath!.isNotEmpty) {
      // Use Image.asset for local files
      imageWidget = Image.asset(
        assetImagePath!,
        key: ValueKey('asset_$assetImagePath'), // Add key
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Asset Error for '$assetImagePath': $error");
          return Container( // Placeholder on error
            color: theme.colorScheme.surfaceVariant,
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          );
        },
      );
    }
    // 2. Fallback to Network Image
    else if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http')) {
       // Use Image.network ONLY for valid URLs
       imageWidget = Image.network(
        imageUrl!,
        key: ValueKey('network_$imageUrl'), // Add key
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container( // Loading placeholder
            color: theme.colorScheme.surfaceVariant,
            alignment: Alignment.center,
            child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Network Error for '$imageUrl': $error");
          return Container( // Placeholder on error
            color: theme.colorScheme.surfaceVariant,
            alignment: Alignment.center,
            child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          );
        },
      );
    }
    // 3. If neither is valid, show placeholder
    else {
      imageWidget = Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
      );
    }

    // --- Card Structure ---
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        color: backgroundColor ?? theme.cardTheme.color ?? theme.cardColor,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        elevation: theme.cardTheme.elevation ?? 1,
        shape: theme.cardTheme.shape ?? RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
         ),
        child: SizedBox(
          height: height,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text Area
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall / 2),
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Image Area
                Expanded(
                  flex: 2,
                  child: imageWidget, // Use the determined image widget
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}