import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../core/widgets/badges/status_badge.dart';
import '../../../../shared/domain/entities/appointment.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const UpcomingAppointmentCard({
    super.key,
    required this.appointment,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Upcoming Appointment',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(
                    label: appointment.statusLabel,
                    color: _getStatusColor(appointment.status),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: appointment.doctor?.avatar != null
                        ? NetworkImage(appointment.doctor!.avatar!)
                        : null,
                    child: appointment.doctor?.avatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctor?.displayName ?? 'Doctor',
                          style: AppTypography.h6,
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          appointment.doctor?.specialty ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space16),
              const Divider(),
              const SizedBox(height: AppTokens.space12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppTokens.iconSm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(appointment.scheduledAt),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: AppTokens.iconSm,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    DateFormat('hh:mm a').format(appointment.scheduledAt),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              if (appointment.tokenNumber != null) ...[
                const SizedBox(height: AppTokens.space8),
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: AppTokens.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppTokens.space8),
                    Text(
                      'Token: ${appointment.tokenNumber}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (appointment.queuePosition != null) ...[
                      const SizedBox(width: AppTokens.space8),
                      Text(
                        '(Queue: ${appointment.queuePosition})',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.info;
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.inProgress:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.noShow:
        return AppColors.gray500;
    }
  }
}