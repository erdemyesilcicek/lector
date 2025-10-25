// lib/widgets/generated_cover_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_constants.dart';
import 'package:lector/core/constants/text_styles.dart';

class GeneratedCover extends StatelessWidget {
  final String title;
  final String author;

  const GeneratedCover({super.key, required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(1,1),
                    )
                  ]
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'by $author',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}