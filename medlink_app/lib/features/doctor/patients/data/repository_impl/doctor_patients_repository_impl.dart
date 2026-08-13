import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/patient_summary.dart';
import '../../domain/repository/doctor_patients_repository.dart';

class DoctorPatientsRepositoryImpl implements DoctorPatientsRepository {
  final DioClient _dioClient;

  DoctorPatientsRepositoryImpl(this._dioClient);

  @override
  Future<List<PatientSummary>> getPatients({String? query}) async {
    final response = await _dioClient.get(
      ApiEndpoints.doctorPatients,
      queryParameters: {
        if (query != null) 'q': query,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => PatientSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PatientSummary> getPatientDetail(String patientId) async {
    final response = await _dioClient.get(
      ApiEndpoints.doctorPatientDetail(patientId),
    );

    return PatientSummary.fromJson(response.data as Map<String, dynamic>);
  }
}