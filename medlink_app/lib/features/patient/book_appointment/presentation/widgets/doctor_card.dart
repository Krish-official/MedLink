import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../shared/domain/entities/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundImage: doctor.avatar != null
                    ? NetworkImage(doctor.avatar!)
                    : null,
                child: doctor.avatar == null
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              const SizedBox(width: AppTokens.space16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.displayName,
                      style: AppTypography.h6,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      doctor.specialty,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppTokens.space4),
                        Text(
                          '${doctor.rating.toStringAsFixed(1)} (${doctor.reviewCount})',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(width: AppTokens.space16),
                        const Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppTokens.space4),
                        Text(
                          '${doctor.experienceYears ?? 0} years',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (doctor.consultationFee > 0) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        '₹${doctor.consultationFee} consultation fee',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}