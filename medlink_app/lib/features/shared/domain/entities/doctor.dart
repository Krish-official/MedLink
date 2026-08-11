import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
abstract class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String specialty,
    String? avatar,
    String? phone,
    String? bio,
    String? qualifications,
    int? experienceYears,
    String? clinicAddress,
    @Default(0) double rating,
    @Default(0) int reviewCount,
    @Default(true) bool isAvailable,
    @Default(500) int consultationFee,
    DateTime? createdAt,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
}

extension DoctorX on Doctor {
  String get fullName => '$firstName $lastName';
  String get displayName => 'Dr. $fullName';
}