import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../../../shared/domain/entities/appointment.dart';
import '../../../shared/domain/entities/time_slot.dart';
import 'providers.dart';

class SlotPickerScreen extends ConsumerWidget {
  const SlotPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(selectedDoctorProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final slotsAsync = ref.watch(availableSlotsProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Time Slot')),
        body: const Center(child: Text('No doctor selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
      ),
      body: Column(
        children: [
          // Doctor Info Header
          Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            color: AppColors.surfaceVariant,
            child: Row(
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
                      Text(doctor.displayName, style: AppTypography.h6),
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
          ),

          // Date Picker
          Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Date', style: AppTypography.labelLarge),
                const SizedBox(height: AppTokens.space12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, __) => const SizedBox(width: AppTokens.space8),
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;

                      return _DateChip(
                        date: date,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).state = date;
                          ref.read(selectedSlotProvider.notifier).state = null;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Time Slots
          Expanded(
            child: slotsAsync.when(
              loading: () => const LoadingState(),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(availableSlotsProvider),
              ),
              data: (slots) {
                if (slots.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_busy,
                    title: 'No slots available',
                    message: 'Please try a different date',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppTokens.space12,
                    mainAxisSpacing: AppTokens.space12,
                    childAspectRatio: 2,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected = selectedSlot?.id == slot.id;

                    return _SlotChip(
                      slot: slot,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedSlotProvider.notifier).state = slot;
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Book Button
          Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray200,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: PrimaryButton(
                label: 'Continue',
                onPressed: selectedSlot != null
                    ? () => context.push('/patient/book-appointment/confirm')
                    : null,
                fullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              DateFormat('dd').format(date),
              style: AppTypography.h5.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !slot.isAvailable || slot.isFull;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space8),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.gray100
              : isSelected
                  ? AppColors.primary
                  : AppColors.surface,
          border: Border.all(
            color: isDisabled
                ? AppColors.gray200
                : isSelected
                    ? AppColors.primary
                    : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Center(
          child: Text(
            slot.timeRange,
            style: AppTypography.labelMedium.copyWith(
              color: isDisabled
                  ? AppColors.textDisabled
                  : isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}