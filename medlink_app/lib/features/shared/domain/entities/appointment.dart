import 'package:freezed_annotation/freezed_annotation.dart';
import 'doctor.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

enum AppointmentType {
  checkup,
  followUp,
  emergency,
  consultation,
}

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String patientId,
    required String doctorId,
    required DateTime scheduledAt,
    required AppointmentStatus status,
    required AppointmentType type,
    Doctor? doctor, // Populated in list views
    String? patientName, // For doctor's view
    String? patientAvatar,
    String? symptoms,
    String? notes,
    int? tokenNumber,
    int? queuePosition,
    String? prescriptionId,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}

extension AppointmentX on Appointment {
  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());
  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool get canCancel =>
      status == AppointmentStatus.scheduled ||
      status == AppointmentStatus.confirmed;
  bool get canReschedule => canCancel;

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }
}