import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/domain/entities/doctor.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/badges/status_badge.dart';
import '../../../shared/domain/entities/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onCancel,
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
              // Header: Doctor info + Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: appointment.doctor?.avatar != null
                        ? NetworkImage(appointment.doctor!.avatar!)
                        : null,
                    child: appointment.doctor?.avatar == null
                        ? const Icon(Icons.person, size: 24)
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
                        Text(
                          appointment.doctor?.specialty ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: appointment.statusLabel,
                    color: _getStatusColor(appointment.status),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space16),
              const Divider(),
              const SizedBox(height: AppTokens.space12),

              // Date & Time
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppTokens.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(appointment.scheduledAt),
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(width: AppTokens.space16),
                  const Icon(
                    Icons.access_time,
                    size: AppTokens.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    DateFormat('hh:mm a').format(appointment.scheduledAt),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),

              // Token Number (if available)
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
                        color: AppColors.primary,
                      ),
                    ),
                    if (appointment.queuePosition != null) ...[
                      const SizedBox(width: AppTokens.space8),
                      Text(
                        '(Position: ${appointment.queuePosition})',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Actions
              if (onCancel != null) ...[
                const SizedBox(height: AppTokens.space16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: AppTokens.iconSm),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
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