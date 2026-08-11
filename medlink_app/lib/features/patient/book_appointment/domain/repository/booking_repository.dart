import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/domain/entities/time_slot.dart';
import '../../../../shared/domain/entities/appointment.dart';
import '../../data/models/booking_request_dto.dart';

abstract class BookingRepository {
  Future<List<Doctor>> searchDoctors({
    String? query,
    String? specialty,
  });

  Future<List<String>> getSpecialties();

  Future<Doctor> getDoctorDetails(String doctorId);

  Future<List<TimeSlot>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  });

  Future<Appointment> bookAppointment(BookingRequestDto request);
}