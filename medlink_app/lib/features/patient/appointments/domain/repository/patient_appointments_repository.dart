import '../../../../shared/domain/entities/appointment.dart';

abstract class PatientAppointmentsRepository {
  Future<List<Appointment>> getAppointments({
    AppointmentStatus? status,
    bool? upcoming,
  });

  Future<Appointment> getAppointmentDetail(String appointmentId);

  Future<void> cancelAppointment({
    required String appointmentId,
    String? reason,
  });

  Future<Appointment> rescheduleAppointment({
    required String appointmentId,
    required String newTimeSlotId,
    required DateTime newScheduledAt,
  });
}