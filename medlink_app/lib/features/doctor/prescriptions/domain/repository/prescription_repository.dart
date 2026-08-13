import '../entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<List<Prescription>> getPrescriptions({String? patientId});
  Future<Prescription> getPrescriptionDetail(String id);
  Future<Prescription> createPrescription(Prescription prescription);
  Future<String> uploadPrescriptionImage(String filePath);
}