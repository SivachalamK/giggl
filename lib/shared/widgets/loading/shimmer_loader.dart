import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 12,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.inputFill,
      highlightColor: colors.card,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerLoader(height: 200, borderRadius: 20),
    );
  }
}
