import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/entities/availability_slot.dart';
import '../domain/entities/holiday.dart';
import '../data/repository_impl/schedule_repository_impl.dart';
import '../domain/repository/schedule_repository.dart';

// Repository Provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(DioClient());
});

// Availability Slots Provider
final availabilitySlotsProvider = FutureProvider<List<AvailabilitySlot>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getAvailability();
});

// Holidays Provider
final holidaysProvider = FutureProvider<List<Holiday>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getHolidays();
});

// Selected Date Provider (for calendar)
final selectedScheduleDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});