import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: AppColors.gray100,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.gray100,
          child: const Icon(Icons.error_outline, color: AppColors.error),
        ),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
      ),
    );
  }
}

class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.gray200,
        child: fallbackText != null
            ? Text(
                fallbackText!,
                style: TextStyle(
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              )
            : Icon(Icons.person, size: radius * 0.8, color: AppColors.gray400),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(imageUrl!),
      backgroundColor: AppColors.gray100,
    );
  }
}