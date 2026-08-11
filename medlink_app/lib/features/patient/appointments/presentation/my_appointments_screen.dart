import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../shared/domain/entities/appointment.dart';
import 'providers.dart';
import 'widgets/appointment_card.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(appointmentFilterProvider);
    final appointmentsAsync = ref.watch(patientAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppointmentFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTokens.space8),
                    child: FilterChip(
                      label: Text(_getFilterLabel(f)),
                      selected: filter == f,
                      onSelected: (_) {
                        ref.read(appointmentFilterProvider.notifier).state = f;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(patientAppointmentsProvider);
              },
              child: appointmentsAsync.when(
                loading: () => const LoadingState(),
                error: (error, stack) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(patientAppointmentsProvider),
                ),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return EmptyState(
                      icon: Icons.event_busy,
                      title: 'No appointments',
                      message: _getEmptyMessage(filter),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppTokens.space16),
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                        appointment: appointments[index],
                        onTap: () {
                          // TODO: Navigate to appointment detail
                        },
                        onCancel: appointments[index].canCancel
                            ? () => _showCancelDialog(context, ref, appointments[index])
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return 'All';
      case AppointmentFilter.upcoming:
        return 'Upcoming';
      case AppointmentFilter.past:
        return 'Past';
      case AppointmentFilter.cancelled:
        return 'Cancelled';
    }
  }

  String _getEmptyMessage(AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return 'You have no appointments yet';
      case AppointmentFilter.upcoming:
        return 'You have no upcoming appointments';
      case AppointmentFilter.past:
        return 'You have no past appointments';
      case AppointmentFilter.cancelled:
        return 'You have no cancelled appointments';
    }
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this appointment?',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why are you cancelling?',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await ref.read(
                  cancelAppointmentProvider((
                    appointment.id,
                    reasonController.text.trim().isEmpty
                        ? null
                        : reasonController.text.trim(),
                  )).future,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment cancelled successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}