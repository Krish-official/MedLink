import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_record.freezed.dart';
part 'medical_record.g.dart';

enum RecordType {
  labReport,
  imaging,
  document,
  prescription,
  discharge,
  other,
}

@freezed
class MedicalRecord with _$MedicalRecord {
  const factory MedicalRecord({
    required String id,
    required String patientId,
    required String title,
    required RecordType type,
    required DateTime uploadedAt,
    required String fileUrl,
    String? description,
    String? uploadedBy,
    String? doctorId,
    String? fileType,
    int? fileSize,
    DateTime? recordDate,
    Map<String, dynamic>? metadata,
  }) = _MedicalRecord;

  factory MedicalRecord.fromJson(Map<String, dynamic> json) =>
      _$MedicalRecordFromJson(json);
}

extension MedicalRecordX on MedicalRecord {
  String get typeLabel {
    switch (type) {
      case RecordType.labReport:
        return 'Lab Report';
      case RecordType.imaging:
        return 'Imaging';
      case RecordType.document:
        return 'Document';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.discharge:
        return 'Discharge Summary';
      case RecordType.other:
        return 'Other';
    }
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}