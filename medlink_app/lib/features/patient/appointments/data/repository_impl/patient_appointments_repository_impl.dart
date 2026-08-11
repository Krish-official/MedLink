import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../shared/domain/entities/appointment.dart';
import '../../domain/repository/patient_appointments_repository.dart';

class PatientAppointmentsRepositoryImpl implements PatientAppointmentsRepository {
  final DioClient _dioClient;

  PatientAppointmentsRepositoryImpl(this._dioClient);

  @override
  Future<List<Appointment>> getAppointments({
    AppointmentStatus? status,
    bool? upcoming,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.patientAppointments,
      queryParameters: {
        if (status != null) 'status': status.name,
        if (upcoming != null) 'upcoming': upcoming,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appointment> getAppointmentDetail(String appointmentId) async {
    final response = await _dioClient.get(
      ApiEndpoints.appointmentDetail(appointmentId),
    );

    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelAppointment({
    required String appointmentId,
    String? reason,
  }) async {
    await _dioClient.post(
      ApiEndpoints.cancelAppointment(appointmentId),
      data: {
        if (reason != null) 'reason': reason,
      },
    );
  }

  @override
  Future<Appointment> rescheduleAppointment({
    required String appointmentId,
    required String newTimeSlotId,
    required DateTime newScheduledAt,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.rescheduleAppointment(appointmentId),
      data: {
        'timeSlotId': newTimeSlotId,
        'scheduledAt': newScheduledAt.toIso8601String(),
      },
    );

    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }
}