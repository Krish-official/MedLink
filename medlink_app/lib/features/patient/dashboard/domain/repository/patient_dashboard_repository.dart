import '../../data/models/dashboard_data_dto.dart';

abstract class PatientDashboardRepository {
  Future<DashboardDataDto> getDashboardData();
}