import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../../../shared/domain/entities/appointment.dart';
import 'providers.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  ConsumerState<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends ConsumerState<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  AppointmentType _selectedType = AppointmentType.consultation;

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final doctor = ref.read(selectedDoctorProvider);
    final slot = ref.read(selectedSlotProvider);

    if (doctor == null || slot == null) return;

    try {
      await ref.read(bookingStateProvider.notifier).bookAppointment(
            doctorId: doctor.id,
            timeSlotId: slot.id,
            scheduledAt: slot.startTime,
            type: _selectedType,
            symptoms: _symptomsController.text.trim().isEmpty
                ? null
                : _symptomsController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        // Navigate to success screen
        context.go('/patient/book-appointment/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(selectedDoctorProvider);
    final slot = ref.watch(selectedSlotProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final bookingState = ref.watch(bookingStateProvider);

    if (doctor == null || slot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Booking')),
        body: const Center(child: Text('Missing booking information')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appointment Summary Card
              Card(
                elevation: AppTokens.elevationSm,
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Summary',
                        style: AppTypography.h6,
                      ),
                      const SizedBox(height: AppTokens.space16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: doctor.avatar != null
                                ? NetworkImage(doctor.avatar!)
                                : null,
                            child: doctor.avatar == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.displayName,
                                  style: AppTypography.h6,
                                ),
                                Text(
                                  doctor.specialty,
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
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                      ),
                      const SizedBox(height: AppTokens.space12),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: slot.timeRange,
                      ),
                      if (doctor.consultationFee > 0) ...[
                        const SizedBox(height: AppTokens.space12),
                        _InfoRow(
                          icon: Icons.payments_outlined,
                          label: 'Consultation Fee',
                          value: '₹${doctor.consultationFee}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space24),

              // Appointment Type
              Text('Appointment Type', style: AppTypography.labelLarge),
              const SizedBox(height: AppTokens.space12),
              Wrap(
                spacing: AppTokens.space8,
                children: AppointmentType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getTypeLabel(type)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTokens.space24),

              // Symptoms (optional)
              Text('Symptoms (Optional)', style: AppTypography.labelLarge),
              const SizedBox(height: AppTokens.space8),
              TextFormField(
                controller: _symptomsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe your symptoms...',
                ),
              ),
              const SizedBox(height: AppTokens.space16),

              // Additional Notes (optional)
              Text('Additional Notes (Optional)', style: AppTypography.labelLarge),
              const SizedBox(height: AppTokens.space8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any specific concerns or questions...',
                ),
              ),
              const SizedBox(height: AppTokens.space32),

              // Buttons
              PrimaryButton(
                label: 'Confirm Booking',
                onPressed: bookingState.isLoading ? null : _handleBooking,
                isLoading: bookingState.isLoading,
                fullWidth: true,
              ),
              const SizedBox(height: AppTokens.space12),
              SecondaryButton(
                label: 'Cancel',
                onPressed: bookingState.isLoading ? null : () => context.pop(),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.consultation:
        return 'Consultation';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppTokens.iconSm, color: AppColors.primary),
        const SizedBox(width: AppTokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
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
          ),
        ),
      ],
    );
  }
}