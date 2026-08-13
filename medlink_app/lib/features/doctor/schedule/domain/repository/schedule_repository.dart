import '../entities/availability_slot.dart';
import '../entities/holiday.dart';

abstract class ScheduleRepository {
  Future<List<AvailabilitySlot>> getAvailability();
  Future<AvailabilitySlot> createAvailability(AvailabilitySlot slot);
  Future<AvailabilitySlot> updateAvailability(AvailabilitySlot slot);
  Future<void> deleteAvailability(String slotId);
  
  Future<List<Holiday>> getHolidays();
  Future<Holiday> createHoliday(Holiday holiday);
  Future<void> deleteHoliday(String holidayId);
}