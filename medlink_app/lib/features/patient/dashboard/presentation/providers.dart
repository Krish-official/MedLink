import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/models/dashboard_data_dto.dart';
import '../data/repository_impl/patient_dashboard_repository_impl.dart';
import '../domain/repository/patient_dashboard_repository.dart';

// Repository Provider
final patientDashboardRepositoryProvider = Provider<PatientDashboardRepository>((ref) {
  return PatientDashboardRepositoryImpl(DioClient());
});

// Dashboard Data Provider
final patientDashboardDataProvider = FutureProvider<DashboardDataDto>((ref) async {
  final repository = ref.watch(patientDashboardRepositoryProvider);
  return repository.getDashboardData();
});