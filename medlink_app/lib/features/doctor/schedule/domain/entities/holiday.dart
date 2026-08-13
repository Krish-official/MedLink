import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday.freezed.dart';
part 'holiday.g.dart';

@freezed
abstract class Holiday with _$Holiday {
  const factory Holiday({
    required String id,
    required String doctorId,
    required DateTime date,
    required String reason,
    @Default(false) bool isFullDay,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}