import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';

enum PickerType { date, time, dateTime }

class DateTimePickerField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final DateTime? value;
  final PickerType type;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const DateTimePickerField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.value,
    this.type = PickerType.date,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  Future<void> _pick(BuildContext context) async {
    DateTime? result = value;

    if (type == PickerType.date || type == PickerType.dateTime) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
      );
      if (pickedDate == null) return;
      result = pickedDate;
    }

    if (type == PickerType.time || type == PickerType.dateTime) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
      );
      if (pickedTime == null) return;
      result = DateTime(
        result!.year,
        result.month,
        result.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }

    onChanged?.call(result);
  }

  String _displayText() {
    if (value == null) return hintText ?? 'Select';
    switch (type) {
      case PickerType.date:
        return AppFormatters.formatDate(value!);
      case PickerType.time:
        return AppFormatters.formatTime(value!);
      case PickerType.dateTime:
        return AppFormatters.formatDateTime(value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.labelMedium),
          const SizedBox(height: AppTokens.space8),
        ],
        InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space12,
            ),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.gray100,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.gray200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  type == PickerType.time ? Icons.access_time : Icons.calendar_today,
                  size: AppTokens.iconSm,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    _displayText(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: hasValue ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppTokens.space4),
          Text(
            errorText!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}