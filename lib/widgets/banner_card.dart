// lib/widgets/banner_card.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';

class BannerCard extends StatelessWidget {
  final String title;
  final String description;
  final String? assetImagePath;
  final String? imageUrl;
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
  }) : assert(
         assetImagePath != null || imageUrl != null,
         'BannerCard requires either assetImagePath or imageUrl.',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget imageWidget;
    bool imageAvailable = false;

    if (assetImagePath != null && assetImagePath!.isNotEmpty) {
      imageAvailable = true;
      imageWidget = Image.asset(
        assetImagePath!,
        key: ValueKey('asset_$assetImagePath'),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Asset Error for '$assetImagePath': $error");
          imageAvailable = false;
          return _buildPlaceholderImage(theme);
        },
      );
    } else if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        imageUrl!.startsWith('http')) {
      imageAvailable = true;
      imageWidget = Image.network(
        imageUrl!,
        key: ValueKey('network_$imageUrl'),
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholderImage(theme, isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          print("!!! BannerCard Network Error for '$imageUrl': $error");
          imageAvailable = false;
          return _buildPlaceholderImage(theme);
        },
      );
    } else {
      imageAvailable = false;
      imageWidget = _buildPlaceholderImage(theme);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Card(
        color: backgroundColor ?? theme.cardTheme.color ?? theme.cardColor,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        elevation: theme.cardTheme.elevation ?? 1,
        shape:
            theme.cardTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
        child: SizedBox(
          height: height ?? 120.0,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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

                Expanded(
                  flex: 2,
                  child: Container(
                    color: imageAvailable
                        ? Colors.transparent
                        : theme.colorScheme.surfaceVariant,
                    padding: const EdgeInsets.all(
                      AppConstants.paddingSmall / 2,
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                        child: imageWidget,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme, {bool isLoading = false}) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          : Icon(
              Icons.image_not_supported_outlined,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
    );
  }
}
