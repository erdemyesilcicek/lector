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

class GridShimmer extends StatelessWidget {
  const GridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerLoading(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            SizedBox(height: 8),
            ShimmerLoading(width: 80, height: 12),
            SizedBox(height: 4),
            ShimmerLoading(width: 60, height: 10),
          ],
        );
      },
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          ShimmerLoading(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(50),
          ),
          const SizedBox(height: 20),
          const ShimmerLoading(width: 150, height: 20),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 100, height: 14),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  ShimmerLoading(width: 60, height: 40),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 50, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  const ListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ShimmerLoading(
                width: 50,
                height: 75,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 120, height: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
