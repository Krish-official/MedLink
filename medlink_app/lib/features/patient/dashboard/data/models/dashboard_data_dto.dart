import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/domain/entities/appointment.dart';

part 'dashboard_data_dto.freezed.dart';
part 'dashboard_data_dto.g.dart';

@freezed
abstract class DashboardDataDto with _$DashboardDataDto {
  const factory DashboardDataDto({
    Appointment? upcomingAppointment,
    @Default(0) int totalAppointments,
    @Default(0) int completedAppointments,
    @Default(0) int cancelledAppointments,
  }) = _DashboardDataDto;

  factory DashboardDataDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataDtoFromJson(json);
}