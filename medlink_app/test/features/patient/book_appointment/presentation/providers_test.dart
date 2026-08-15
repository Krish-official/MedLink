import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medcare_flutter/features/patient/book_appointment/domain/repository/booking_repository.dart';
import 'package:medcare_flutter/features/patient/book_appointment/presentation/providers.dart';
import 'package:medcare_flutter/features/shared/domain/entities/doctor.dart';

@GenerateMocks([BookingRepository])
import 'providers_test.mocks.dart';

void main() {
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
  });

  group('doctorSearchProvider', () {
    test('should fetch doctors when query is null', () async {
      // Arrange
      final doctors = [
        const Doctor(
          id: '1',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          specialty: 'Cardiology',
        ),
      ];

      when(mockRepository.searchDoctors(query: null, specialty: null))
          .thenAnswer((_) async => doctors);

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Act
      final result = await container.read(doctorSearchProvider.future);

      // Assert
      expect(result, equals(doctors));
      verify(mockRepository.searchDoctors(query: null, specialty: null))
          .called(1);
    });

    test('should fetch doctors with search query', () async {
      // Arrange
      const query = 'John';
      final doctors = [
        const Doctor(
          id: '1',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          specialty: 'Cardiology',
        ),
      ];

      when(mockRepository.searchDoctors(query: query, specialty: null))
          .thenAnswer((_) async => doctors);

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
          doctorSearchQueryProvider.overrideWith((ref) => query),
        ],
      );

      // Act
      final result = await container.read(doctorSearchProvider.future);

      // Assert
      expect(result, equals(doctors));
      verify(mockRepository.searchDoctors(query: query, specialty: null))
          .called(1);
    });
  });
}