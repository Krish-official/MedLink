import '../entities/patient_summary.dart';

abstract class DoctorPatientsRepository {
  Future<List<PatientSummary>> getPatients({String? query});
  Future<PatientSummary> getPatientDetail(String patientId);
}