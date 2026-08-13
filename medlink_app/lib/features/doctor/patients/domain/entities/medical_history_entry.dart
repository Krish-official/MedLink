import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_history_entry.freezed.dart';
part 'medical_history_entry.g.dart';

enum HistoryType {
  diagnosis,
  prescription,
  labTest,
  procedure,
  note,
}

@freezed
class MedicalHistoryEntry with _$MedicalHistoryEntry {
  const factory MedicalHistoryEntry({
    required String id,
    required String patientId,
    required DateTime date,
    required HistoryType type,
    required String title,
    String? description,
    String? doctorId,
    String? doctorName,
    String? attachmentUrl,
    Map<String, dynamic>? metadata,
  }) = _MedicalHistoryEntry;

  factory MedicalHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MedicalHistoryEntryFromJson(json);
}