import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../shared/domain/entities/appointment.dart';

part 'doctor_dashboard_dto.freezed.dart';
part 'doctor_dashboard_dto.g.dart';

@freezed
abstract class DoctorDashboardDto with _$DoctorDashboardDto {
  const factory DoctorDashboardDto({
    @Default([]) List<Appointment> todayAppointments,
    @Default(0) int totalPatientsToday,
    @Default(0) int completedToday,
    @Default(0) int pendingToday,
    @Default(0) int currentQueueSize,
    Appointment? currentAppointment,
    Appointment? nextAppointment,
  }) = _DoctorDashboardDto;

  factory DoctorDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$DoctorDashboardDtoFromJson(json);
}