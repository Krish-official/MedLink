import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/repository/patient_dashboard_repository.dart';
import '../models/dashboard_data_dto.dart';

class PatientDashboardRepositoryImpl implements PatientDashboardRepository {
  final DioClient _dioClient;

  PatientDashboardRepositoryImpl(this._dioClient);

  @override
  Future<DashboardDataDto> getDashboardData() async {
    final response = await _dioClient.get(
      '${ApiEndpoints.patientProfile}/dashboard',
    );

    return DashboardDataDto.fromJson(response.data as Map<String, dynamic>);
  }
}