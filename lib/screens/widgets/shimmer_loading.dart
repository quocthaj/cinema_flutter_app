// ...existing code...
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[300]!;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class MovieCardShimmer extends StatelessWidget {
  final double imageHeight;

  const MovieCardShimmer({super.key, this.imageHeight = 180});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // image shimmer
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ShimmerLoading(width: double.infinity, height: imageHeight, borderRadius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 150, height: 16),
                SizedBox(height: 8),
                ShimmerLoading(width: 80, height: 14),
                SizedBox(height: 12),
                ShimmerLoading(width: double.infinity, height: 36, borderRadius: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...