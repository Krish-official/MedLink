import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/repository/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final DioClient _dioClient;

  ScheduleRepositoryImpl(this._dioClient);

  @override
  Future<List<AvailabilitySlot>> getAvailability() async {
    final response = await _dioClient.get(ApiEndpoints.doctorAvailability);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => AvailabilitySlot.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AvailabilitySlot> createAvailability(AvailabilitySlot slot) async {
    final response = await _dioClient.post(
      ApiEndpoints.doctorAvailability,
      data: slot.toJson(),
    );
    return AvailabilitySlot.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AvailabilitySlot> updateAvailability(AvailabilitySlot slot) async {
    final response = await _dioClient.put(
      '${ApiEndpoints.doctorAvailability}/${slot.id}',
      data: slot.toJson(),
    );
    return AvailabilitySlot.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAvailability(String slotId) async {
    await _dioClient.delete('${ApiEndpoints.doctorAvailability}/$slotId');
  }

  @override
  Future<List<Holiday>> getHolidays() async {
    final response = await _dioClient.get('${ApiEndpoints.doctorSchedule}/holidays');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Holiday> createHoliday(Holiday holiday) async {
    final response = await _dioClient.post(
      '${ApiEndpoints.doctorSchedule}/holidays',
      data: holiday.toJson(),
    );
    return Holiday.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteHoliday(String holidayId) async {
    await _dioClient.delete('${ApiEndpoints.doctorSchedule}/holidays/$holidayId');
  }
}