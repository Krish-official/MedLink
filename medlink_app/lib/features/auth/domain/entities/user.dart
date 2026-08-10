import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  patient,
  doctor,
  admin,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserX on User {
  String get fullName => '$firstName $lastName';
  bool get isPatient => role == UserRole.patient;
  bool get isDoctor => role == UserRole.doctor;
  bool get isAdmin => role == UserRole.admin;
}