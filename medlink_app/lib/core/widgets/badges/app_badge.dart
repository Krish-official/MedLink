import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

enum BadgeVariant { success, warning, error, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
  });

  ({Color bg, Color fg}) _colorsFor(BadgeVariant v) {
    switch (v) {
      case BadgeVariant.success:
        return (bg: AppColors.successLight, fg: AppColors.success);
      case BadgeVariant.warning:
        return (bg: AppColors.warningLight, fg: AppColors.warning);
      case BadgeVariant.error:
        return (bg: AppColors.errorLight, fg: AppColors.error);
      case BadgeVariant.info:
        return (bg: AppColors.infoLight, fg: AppColors.info);
      case BadgeVariant.neutral:
        return (bg: AppColors.gray100, fg: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: AppTokens.space4,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: colors.fg),
          ),
        ],
      ),
    );
  }
}