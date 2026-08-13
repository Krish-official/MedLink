import '../../data/models/doctor_dashboard_dto.dart';

abstract class DoctorDashboardRepository {
  Future<DoctorDashboardDto> getDashboardData();
  Future<void> startAppointment(String appointmentId);
  Future<void> completeAppointment(String appointmentId);
}