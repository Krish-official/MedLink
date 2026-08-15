import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../shared/domain/entities/medical_record.dart';
import '../../domain/repository/medical_records_repository.dart';

class MedicalRecordsRepositoryImpl implements MedicalRecordsRepository {
  final DioClient _dioClient;

  MedicalRecordsRepositoryImpl(this._dioClient);

  @override
  Future<List<MedicalRecord>> getMedicalRecords({RecordType? type}) async {
    final response = await _dioClient.get(
      ApiEndpoints.medicalRecords,
      queryParameters: {
        if (type != null) 'type': type.name,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => MedicalRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MedicalRecord> uploadMedicalRecord({
    required String title,
    required RecordType type,
    required File file,
    String? description,
    DateTime? recordDate,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'title': title,
      'type': type.name,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      if (description != null) 'description': description,
      if (recordDate != null) 'recordDate': recordDate.toIso8601String(),
    });

    final response = await _dioClient.post(
      ApiEndpoints.uploadMedicalRecord,
      data: formData,
    );

    return MedicalRecord.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMedicalRecord(String recordId) async {
    await _dioClient.delete('${ApiEndpoints.medicalRecords}/$recordId');
  }

  @override
  Future<String> downloadMedicalRecord(String recordId) async {
    final response = await _dioClient.get(
      '${ApiEndpoints.medicalRecords}/$recordId/download',
    );
    return response.data['downloadUrl'] as String;
  }
}