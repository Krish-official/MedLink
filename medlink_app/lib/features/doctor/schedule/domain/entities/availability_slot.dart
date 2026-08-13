import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability_slot.freezed.dart';
part 'availability_slot.g.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

@freezed
abstract class AvailabilitySlot with _$AvailabilitySlot {
  const factory AvailabilitySlot({
    required String id,
    required String doctorId,
    required DayOfWeek dayOfWeek,
    required String startTime, // "09:00"
    required String endTime,   // "17:00"
    @Default(30) int slotDuration, // minutes
    @Default(5) int maxPatientsPerSlot,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AvailabilitySlot;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotFromJson(json);
}