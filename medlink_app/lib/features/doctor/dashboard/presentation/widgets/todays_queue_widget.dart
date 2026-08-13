import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/theme/typography.dart';
import '../../../../../core/widgets/badges/status_badge.dart';
import '../../../../shared/domain/entities/appointment.dart';

class TodaysQueueWidget extends StatelessWidget {
  final List<Appointment> appointments;
  final Appointment? currentAppointment;
  final VoidCallback? onRefresh;

  const TodaysQueueWidget({
    super.key,
    required this.appointments,
    this.currentAppointment,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Row(
              children: [
                Text(
                  'Today\'s Queue',
                  style: AppTypography.h6,
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    iconSize: AppTokens.iconSm,
                  ),
              ],
            ),
          ),

          // Current Patient
          if (currentAppointment != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTokens.space16),
              color: AppColors.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Patient',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  _QueueItem(
                    appointment: currentAppointment!,
                    isCurrent: true,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Queue List
          if (appointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTokens.space24),
              child: Center(
                child: Text(
                  'No appointments today',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length > 5 ? 5 : appointments.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _QueueItem(
                  appointment: appointments[index],
                  showPosition: true,
                );
              },
            ),

          if (appointments.length > 5)
            Padding(
              padding: const EdgeInsets.all(AppTokens.space16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full queue view
                  },
                  child: Text('+${appointments.length - 5} more'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final Appointment appointment;
  final bool isCurrent;
  final bool showPosition;

  const _QueueItem({
    required this.appointment,
    this.isCurrent = false,
    this.showPosition = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Row(
        children: [
          if (appointment.tokenNumber != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Center(
                child: Text(
                  '${appointment.tokenNumber}',
                  style: AppTypography.h6.copyWith(
                    color: isCurrent ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName ?? 'Patient',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: AppTokens.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppTokens.space4),
                    Text(
                      DateFormat('hh:mm a').format(appointment.scheduledAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (appointment.type == AppointmentType.emergency) ...[
                      const SizedBox(width: AppTokens.space8),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: AppTokens.iconXs,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppTokens.space4),
                      Text(
                        'Emergency',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (showPosition && appointment.queuePosition != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space8,
                vertical: AppTokens.space4,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppTokens.radiusXs),
              ),
              child: Text(
                '#${appointment.queuePosition}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (isCurrent)
            StatusBadge(
              label: 'In Progress',
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }
}