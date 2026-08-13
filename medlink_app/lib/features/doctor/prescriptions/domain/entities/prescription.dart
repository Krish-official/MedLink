import 'package:freezed_annotation/freezed_annotation.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    required String patientId,
    required String doctorId,
    required DateTime prescribedAt,
    required List<Medication> medications,
    String? patientName,
    String? doctorName,
    String? diagnosis,
    String? notes,
    String? followUpDate,
    String? attachmentUrl,
    DateTime? createdAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);
}

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    String? instructions,
    String? timing,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}