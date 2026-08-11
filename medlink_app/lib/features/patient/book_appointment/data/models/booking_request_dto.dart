import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_request_dto.freezed.dart';
part 'booking_request_dto.g.dart';

@freezed
abstract class BookingRequestDto with _$BookingRequestDto {
  const factory BookingRequestDto({
    required String doctorId,
    required String timeSlotId,
    required DateTime scheduledAt,
    required String type,
    String? symptoms,
    String? notes,
  }) = _BookingRequestDto;

  factory BookingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestDtoFromJson(json);
}