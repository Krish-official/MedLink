import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTokens.radiusXs),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: double.infinity, height: 16),
                      const SizedBox(height: AppTokens.space8),
                      SkeletonLoader(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space16),
            SkeletonLoader(width: double.infinity, height: 12),
            const SizedBox(height: AppTokens.space8),
            SkeletonLoader(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  final int itemCount;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTokens.space16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}