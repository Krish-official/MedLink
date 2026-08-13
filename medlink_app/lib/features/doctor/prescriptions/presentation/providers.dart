import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/entities/prescription.dart';
import '../data/repository_impl/prescription_repository_impl.dart';
import '../domain/repository/prescription_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

// Repository Provider
final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  return PrescriptionRepositoryImpl(DioClient());
});

// Prescriptions List Provider
final prescriptionsProvider = FutureProvider.family<List<Prescription>, String?>(
  (ref, patientId) async {
    final repository = ref.watch(prescriptionRepositoryProvider);
    return repository.getPrescriptions(patientId: patientId);
  },
);

// Prescription Detail Provider
final prescriptionDetailProvider = FutureProvider.family<Prescription, String>(
  (ref, id) async {
    final repository = ref.watch(prescriptionRepositoryProvider);
    return repository.getPrescriptionDetail(id);
  },
);

// Medication List State (for editor)
final medicationsProvider = StateProvider<List<Medication>>((ref) => []);