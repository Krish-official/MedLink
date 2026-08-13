import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/repository/doctor_dashboard_repository.dart';
import '../models/doctor_dashboard_dto.dart';

class DoctorDashboardRepositoryImpl implements DoctorDashboardRepository {
  final DioClient _dioClient;

  DoctorDashboardRepositoryImpl(this._dioClient);

  @override
  Future<DoctorDashboardDto> getDashboardData() async {
    final response = await _dioClient.get(
      '${ApiEndpoints.doctorProfile}/dashboard',
    );

    return DoctorDashboardDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> startAppointment(String appointmentId) async {
    await _dioClient.post(
      '${ApiEndpoints.appointmentDetail(appointmentId)}/start',
    );
  }

  @override
  Future<void> completeAppointment(String appointmentId) async {
    await _dioClient.post(
      '${ApiEndpoints.appointmentDetail(appointmentId)}/complete',
    );
  }
}