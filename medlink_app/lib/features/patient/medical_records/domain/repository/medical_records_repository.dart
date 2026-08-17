import 'dart:io';
import '../../../../shared/domain/entities/medical_record.dart';

abstract class MedicalRecordsRepository {
  Future<List<MedicalRecord>> getMedicalRecords({RecordType? type});
  
  Future<MedicalRecord> uploadMedicalRecord({
    required String title,
    required RecordType type,
    required File file,
    String? description,
    DateTime? recordDate,
  });
  
  Future<void> deleteMedicalRecord(String recordId);
  Future<String> downloadMedicalRecord(String recordId);
}