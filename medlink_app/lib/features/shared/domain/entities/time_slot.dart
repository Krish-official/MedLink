import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_slot.freezed.dart';
part 'time_slot.g.dart';

@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required String id,
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
    @Default(true) bool isAvailable,
    int? currentQueue,
    int? maxQueue,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
}

extension TimeSlotX on TimeSlot {
  String get timeRange {
    final start = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  bool get isFull => currentQueue != null && maxQueue != null && currentQueue! >= maxQueue!;
}