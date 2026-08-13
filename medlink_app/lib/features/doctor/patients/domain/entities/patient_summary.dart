import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_summary.freezed.dart';
part 'patient_summary.g.dart';

@freezed
class PatientSummary with _$PatientSummary {
  const factory PatientSummary({
    required String id,
    required String firstName,
    required String lastName,
    String? avatar,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    @Default(0) int totalVisits,
    DateTime? lastVisit,
    DateTime? nextAppointment,
  }) = _PatientSummary;

  factory PatientSummary.fromJson(Map<String, dynamic> json) =>
      _$PatientSummaryFromJson(json);
}

extension PatientSummaryX on PatientSummary {
  String get fullName => '$firstName $lastName';
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    return now.year - dateOfBirth!.year;
  }
}