import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/theme/typography.dart';

class StatsSummary extends StatelessWidget {
  final int totalPatients;
  final int completed;
  final int pending;
  final int queueSize;

  const StatsSummary({
    super.key,
    required this.totalPatients,
    required this.completed,
    required this.pending,
    required this.queueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '$totalPatients',
            icon: Icons.people_outline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: _StatCard(
            label: 'Completed',
            value: '$completed',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: '$pending',
            icon: Icons.pending_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppTokens.space12),
        Expanded(
          child: _StatCard(
            label: 'Queue',
            value: '$queueSize',
            icon: Icons.queue_outlined,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space12),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppTokens.iconMd),
            const SizedBox(height: AppTokens.space8),
            Text(
              value,
              style: AppTypography.h5.copyWith(color: color),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}