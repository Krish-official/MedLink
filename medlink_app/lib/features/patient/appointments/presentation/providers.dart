import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/domain/entities/appointment.dart';
import '../data/repository_impl/patient_appointments_repository_impl.dart';
import '../domain/repository/patient_appointments_repository.dart';

// Repository Provider
final patientAppointmentsRepositoryProvider = Provider<PatientAppointmentsRepository>((ref) {
  return PatientAppointmentsRepositoryImpl(DioClient());
});

// Filter State
enum AppointmentFilter { all, upcoming, past, cancelled }

final appointmentFilterProvider = StateProvider<AppointmentFilter>((ref) {
  return AppointmentFilter.upcoming;
});

// Appointments List Provider
final patientAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final repository = ref.watch(patientAppointmentsRepositoryProvider);
  final filter = ref.watch(appointmentFilterProvider);

  switch (filter) {
    case AppointmentFilter.all:
      return repository.getAppointments();
    case AppointmentFilter.upcoming:
      return repository.getAppointments(upcoming: true);
    case AppointmentFilter.past:
      return repository.getAppointments(upcoming: false);
    case AppointmentFilter.cancelled:
      return repository.getAppointments(status: AppointmentStatus.cancelled);
  }
});

// Single Appointment Provider
final appointmentDetailProvider = FutureProvider.family<Appointment, String>((ref, id) async {
  final repository = ref.watch(patientAppointmentsRepositoryProvider);
  return repository.getAppointmentDetail(id);
});

// Cancel Appointment Provider
final cancelAppointmentProvider = FutureProvider.family<void, (String, String?)>(
  (ref, params) async {
    final repository = ref.watch(patientAppointmentsRepositoryProvider);
    final (appointmentId, reason) = params;
    await repository.cancelAppointment(
      appointmentId: appointmentId,
      reason: reason,
    );
    // Invalidate appointments list to refresh
    ref.invalidate(patientAppointmentsProvider);
  },
);