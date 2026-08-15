import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_contact.freezed.dart';
part 'emergency_contact.g.dart';

enum ContactRelationship {
  spouse,
  parent,
  sibling,
  child,
  friend,
  other,
}

@freezed
class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String id,
    required String patientId,
    required String name,
    required String phone,
    required ContactRelationship relationship,
    String? email,
    String? address,
    @Default(false) bool isPrimary,
    DateTime? createdAt,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}