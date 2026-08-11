import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/domain/entities/appointment.dart';
import '../../../shared/domain/entities/doctor.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../../../../core/router/routes.dart';
import 'providers.dart';

class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingStateProvider);
    final appointment = bookingState.appointment;

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No appointment data')),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Success Animation
                      SizedBox(
                        height: 200,
                        child: Icon(
                          Icons.check_circle,
                          size: 120,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppTokens.space24),

                      // Success Message
                      Text(
                        'Booking Confirmed!',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        'Your appointment has been successfully booked',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.space32),

                      // Appointment Details Card
                      Card(
                        elevation: AppTokens.elevationMd,
                        child: Padding(
                          padding: const EdgeInsets.all(AppTokens.space20),
                          child: Column(
                            children: [
                              if (appointment.tokenNumber != null) ...[
                                Text(
                                  'Your Token Number',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppTokens.space8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTokens.space24,
                                    vertical: AppTokens.space12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.radiusMd,
                                    ),
                                  ),
                                  child: Text(
                                    '${appointment.tokenNumber}',
                                    style: AppTypography.h2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppTokens.space20),
                                const Divider(),
                                const SizedBox(height: AppTokens.space16),
                              ],
                              _DetailRow(
                                label: 'Doctor',
                                value: appointment.doctor?.displayName ?? 'Doctor',
                              ),
                              const SizedBox(height: AppTokens.space12),
                              _DetailRow(
                                label: 'Date',
                                value: DateFormat('EEEE, MMM dd, yyyy')
                                    .format(appointment.scheduledAt),
                              ),
                              const SizedBox(height: AppTokens.space12),
                              _DetailRow(
                                label: 'Time',
                                value: DateFormat('hh:mm a')
                                    .format(appointment.scheduledAt),
                              ),
                              const SizedBox(height: AppTokens.space12),
                              _DetailRow(
                                label: 'Status',
                                value: appointment.statusLabel,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.space24),

                      // Info Message
                      Container(
                        padding: const EdgeInsets.all(AppTokens.space16),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: AppTokens.space12),
                            Expanded(
                              child: Text(
                                'You will receive a reminder 30 minutes before your appointment',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.infoDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              const SizedBox(height: AppTokens.space16),
              PrimaryButton(
                label: 'View Appointment',
                onPressed: () {
                  // Clear booking state
                  ref.read(bookingStateProvider.notifier).reset();
                  ref.read(selectedDoctorProvider.notifier).state = null;
                  ref.read(selectedSlotProvider.notifier).state = null;
                  
                  // Navigate to appointments
                  context.go(Routes.patientAppointments);
                },
                fullWidth: true,
              ),
              const SizedBox(height: AppTokens.space12),
              SecondaryButton(
                label: 'Back to Dashboard',
                onPressed: () {
                  // Clear booking state
                  ref.read(bookingStateProvider.notifier).reset();
                  ref.read(selectedDoctorProvider.notifier).state = null;
                  ref.read(selectedSlotProvider.notifier).state = null;
                  
                  context.go(Routes.patientDashboard);
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}