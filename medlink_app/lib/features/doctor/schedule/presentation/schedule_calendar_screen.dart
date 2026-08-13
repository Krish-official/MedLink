import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import 'providers.dart';
import '../domain/entities/availability_slot.dart';

class ScheduleCalendarScreen extends ConsumerWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedScheduleDateProvider);
    final holidaysAsync = ref.watch(holidaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_busy_outlined),
            onPressed: () {
              // Navigate to holidays management
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to availability settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          holidaysAsync.when(
            loading: () => const SizedBox(
              height: 400,
              child: LoadingState(),
            ),
            error: (error, stack) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(holidaysProvider),
            ),
            data: (holidays) => Card(
              margin: const EdgeInsets.all(AppTokens.space16),
              elevation: AppTokens.elevationSm,
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selected, focused) {
                  ref.read(selectedScheduleDateProvider.notifier).state = selected;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: AppTypography.h6,
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) {
                  // Show holidays as markers
                  return holidays.where((h) => isSameDay(h.date, day)).toList();
                },
              ),
            ),
          ),

          // Selected Day Info
          Expanded(
            child: _DayScheduleView(selectedDate: selectedDate),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add availability
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
    );
  }
}

class _DayScheduleView extends ConsumerWidget {
  final DateTime selectedDate;

  const _DayScheduleView({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(availabilitySlotsProvider);
    final dayOfWeek = _getDayOfWeek(selectedDate.weekday);

    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
            style: AppTypography.h6,
          ),
          const SizedBox(height: AppTokens.space16),
          Expanded(
            child: availabilityAsync.when(
              loading: () => const LoadingState(),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(availabilitySlotsProvider),
              ),
              data: (slots) {
                final daySlots = slots.where((s) => s.dayOfWeek == dayOfWeek).toList();

                if (daySlots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 64,
                          color: AppColors.gray300,
                        ),
                        const SizedBox(height: AppTokens.space16),
                        Text(
                          'No availability set for this day',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space16),
                        PrimaryButton(
                          label: 'Add Availability',
                          onPressed: () {
                            // Navigate to add availability
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: daySlots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
                  itemBuilder: (context, index) {
                    return _AvailabilitySlotCard(slot: daySlots[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  DayOfWeek _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}

class _AvailabilitySlotCard extends StatelessWidget {
  final AvailabilitySlot slot;

  const _AvailabilitySlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: slot.isActive ? AppColors.primary : AppColors.gray400,
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.startTime} - ${slot.endTime}',
                    style: AppTypography.h6.copyWith(
                      color: slot.isActive ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    '${slot.slotDuration} min slots • Max ${slot.maxPatientsPerSlot} patients/slot',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: slot.isActive,
              onChanged: (value) {
                // TODO: Update slot active status
              },
            ),
          ],
        ),
      ),
    );
  }
}