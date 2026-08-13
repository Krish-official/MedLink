import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/models/doctor_dashboard_dto.dart';
import '../data/repository_impl/doctor_dashboard_repository_impl.dart';
import '../domain/repository/doctor_dashboard_repository.dart';

// Repository Provider
final doctorDashboardRepositoryProvider = Provider<DoctorDashboardRepository>((ref) {
  return DoctorDashboardRepositoryImpl(DioClient());
});

// Dashboard Data Provider
final doctorDashboardDataProvider = FutureProvider<DoctorDashboardDto>((ref) async {
  final repository = ref.watch(doctorDashboardRepositoryProvider);
  return repository.getDashboardData();
});

// Auto-refresh every 30 seconds for real-time queue updates
final dashboardRefreshProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (count) => count);
});