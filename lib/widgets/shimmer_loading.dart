// lib/widgets/shimmer_loading.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class BookCardShimmer extends StatelessWidget {
  const BookCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerLoading(
              width: 130,
              height: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 100, height: 14),
          const SizedBox(height: 4),
          const ShimmerLoading(width: 80, height: 12),
        ],
      ),
    );
  }
}

class BigCardShimmer extends StatelessWidget {
  const BigCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 280.0;
    const double cardWidth = cardHeight * 0.7;

    return ShimmerLoading(
      width: cardWidth,
      height: cardHeight,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

class BookOfTheDayShimmer extends StatelessWidget {
  const BookOfTheDayShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: ShimmerLoading(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
