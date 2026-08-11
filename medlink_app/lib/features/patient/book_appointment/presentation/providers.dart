import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../../shared/domain/entities/doctor.dart';
import '../../../shared/domain/entities/time_slot.dart';
import '../../../shared/domain/entities/appointment.dart';
import '../data/repository_impl/booking_repository_impl.dart';
import '../domain/repository/booking_repository.dart';
import '../data/models/booking_request_dto.dart';

// Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(DioClient());
});

// Specialties Provider
final specialtiesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getSpecialties();
});

// Doctor Search Provider
final doctorSearchQueryProvider = StateProvider<String?>((ref) => null);
final selectedSpecialtyProvider = StateProvider<String?>((ref) => null);

final doctorSearchProvider = FutureProvider<List<Doctor>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final query = ref.watch(doctorSearchQueryProvider);
  final specialty = ref.watch(selectedSpecialtyProvider);

  return repository.searchDoctors(
    query: query,
    specialty: specialty,
  );
});

// Selected Doctor Provider
final selectedDoctorProvider = StateProvider<Doctor?>((ref) => null);

// Selected Date Provider (for slot picker)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Available Slots Provider
final availableSlotsProvider = FutureProvider<List<TimeSlot>>((ref) async {
  final doctor = ref.watch(selectedDoctorProvider);
  if (doctor == null) return [];

  final date = ref.watch(selectedDateProvider);
  final repository = ref.watch(bookingRepositoryProvider);

  return repository.getAvailableSlots(
    doctorId: doctor.id,
    date: date,
  );
});

// Selected Slot Provider
final selectedSlotProvider = StateProvider<TimeSlot?>((ref) => null);

// Booking State Provider
class BookingState {
  final bool isLoading;
  final Appointment? appointment;
  final String? error;

  BookingState({
    this.isLoading = false,
    this.appointment,
    this.error,
  });

  BookingState copyWith({
    bool? isLoading,
    Appointment? appointment,
    String? error,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      appointment: appointment ?? this.appointment,
      error: error,
    );
  }
}

final bookingStateProvider = StateNotifierProvider<BookingStateNotifier, BookingState>((ref) {
  return BookingStateNotifier(ref.watch(bookingRepositoryProvider));
});

class BookingStateNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingStateNotifier(this._repository) : super(BookingState());

  Future<void> bookAppointment({
    required String doctorId,
    required String timeSlotId,
    required DateTime scheduledAt,
    required AppointmentType type,
    String? symptoms,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = BookingRequestDto(
        doctorId: doctorId,
        timeSlotId: timeSlotId,
        scheduledAt: scheduledAt,
        type: type.name,
        symptoms: symptoms,
        notes: notes,
      );

      final appointment = await _repository.bookAppointment(request);
      state = state.copyWith(
        isLoading: false,
        appointment: appointment,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = BookingState();
  }
}