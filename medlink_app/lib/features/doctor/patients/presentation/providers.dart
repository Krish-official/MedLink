import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/entities/patient_summary.dart';
import '../data/repository_impl/doctor_patients_repository_impl.dart';
import '../domain/repository/doctor_patients_repository.dart';

// Repository Provider
final doctorPatientsRepositoryProvider = Provider<DoctorPatientsRepository>((ref) {
  return DoctorPatientsRepositoryImpl(DioClient());
});

// Search Query Provider
final patientSearchQueryProvider = StateProvider<String?>((ref) => null);

// Patients List Provider
final doctorPatientsProvider = FutureProvider<List<PatientSummary>>((ref) async {
  final repository = ref.watch(doctorPatientsRepositoryProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return repository.getPatients(query: query);
});

// Patient Detail Provider
final patientDetailProvider = FutureProvider.family<PatientSummary, String>(
  (ref, patientId) async {
    final repository = ref.watch(doctorPatientsRepositoryProvider);
    return repository.getPatientDetail(patientId);
  },
);