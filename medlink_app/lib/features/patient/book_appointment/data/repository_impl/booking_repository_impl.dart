import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/domain/entities/time_slot.dart';
import '../../../../shared/domain/entities/appointment.dart';
import '../../domain/repository/booking_repository.dart';
import '../models/booking_request_dto.dart';

class BookingRepositoryImpl implements BookingRepository {
  final DioClient _dioClient;

  BookingRepositoryImpl(this._dioClient);

  @override
  Future<List<Doctor>> searchDoctors({
    String? query,
    String? specialty,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.doctorSearch,
      queryParameters: {
        if (query != null) 'q': query,
        if (specialty != null) 'specialty': specialty,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getSpecialties() async {
    final response = await _dioClient.get(ApiEndpoints.specialties);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.cast<String>();
  }

  @override
  Future<Doctor> getDoctorDetails(String doctorId) async {
    final response = await _dioClient.get(
      ApiEndpoints.doctorDetail(doctorId),
    );

    return Doctor.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.appointmentSlots,
      queryParameters: {
        'doctorId': doctorId,
        'date': date.toIso8601String(),
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => TimeSlot.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appointment> bookAppointment(BookingRequestDto request) async {
    final response = await _dioClient.post(
      ApiEndpoints.bookAppointment,
      data: request.toJson(),
    );

    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }
}