import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/repository/prescription_repository.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final DioClient _dioClient;

  PrescriptionRepositoryImpl(this._dioClient);

  @override
  Future<List<Prescription>> getPrescriptions({String? patientId}) async {
    final response = await _dioClient.get(
      ApiEndpoints.prescriptions,
      queryParameters: {
        if (patientId != null) 'patientId': patientId,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Prescription.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Prescription> getPrescriptionDetail(String id) async {
    final response = await _dioClient.get(
      ApiEndpoints.prescriptionDetail(id),
    );

    return Prescription.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    final response = await _dioClient.post(
      ApiEndpoints.createPrescription,
      data: prescription.toJson(),
    );

    return Prescription.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> uploadPrescriptionImage(String filePath) async {
    // TODO: Implement file upload
    throw UnimplementedError('File upload not implemented');
  }
}