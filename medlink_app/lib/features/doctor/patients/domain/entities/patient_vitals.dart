import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_vitals.freezed.dart';
part 'patient_vitals.g.dart';

@freezed
class PatientVitals with _$PatientVitals {
  const factory PatientVitals({
    required String id,
    required String patientId,
    required DateTime recordedAt,
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    double? heartRate,
    double? temperature,
    double? oxygenSaturation,
    double? weight,
    double? height,
    double? bmi,
    String? notes,
    String? recordedBy,
  }) = _PatientVitals;

  factory PatientVitals.fromJson(Map<String, dynamic> json) =>
      _$PatientVitalsFromJson(json);
}

extension PatientVitalsX on PatientVitals {
  String? get bloodPressure {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    return '${bloodPressureSystolic!.toInt()}/${bloodPressureDiastolic!.toInt()}';
  }
}