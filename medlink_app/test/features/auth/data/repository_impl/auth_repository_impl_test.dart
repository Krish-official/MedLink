import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:medcare_flutter/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:medcare_flutter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:medcare_flutter/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:medcare_flutter/features/auth/data/models/login_request_dto.dart';
import 'package:medcare_flutter/features/auth/data/models/auth_response_dto.dart';
import 'package:medcare_flutter/features/auth/domain/entities/user.dart';

@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('login', () {
    const email = 'test@example.com';
    const password = 'password123';
    const accessToken = 'access_token';
    const refreshToken = 'refresh_token';

    final user = User(
      id: '1',
      email: email,
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.patient,
    );

    final authResponse = AuthResponseDto(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    test('should return user and tokens on successful login', () async {
      // Arrange
      when(mockRemoteDataSource.login(any))
          .thenAnswer((_) async => authResponse);
      when(mockLocalDataSource.saveTokens(
        accessToken: anyNamed('accessToken'),
        refreshToken: anyNamed('refreshToken'),
      )).thenAnswer((_) async => {});
      when(mockLocalDataSource.saveUser(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.login(email: email, password: password);

      // Assert
      expect(result.$1, equals(user));
      expect(result.$2.accessToken, equals(accessToken));
      expect(result.$2.refreshToken, equals(refreshToken));
      verify(mockRemoteDataSource.login(any)).called(1);
      verify(mockLocalDataSource.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      )).called(1);
      verify(mockLocalDataSource.saveUser(user)).called(1);
    });

    test('should throw exception when login fails', () async {
      // Arrange
      when(mockRemoteDataSource.login(any))
          .thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => repository.login(email: email, password: password),
        throwsException,
      );
    });
  });

  group('logout', () {
    test('should clear local data even if remote logout fails', () async {
      // Arrange
      when(mockRemoteDataSource.logout()).thenThrow(Exception('Network error'));
      when(mockLocalDataSource.clearAll()).thenAnswer((_) async => {});

      // Act
      await repository.logout();

      // Assert
      verify(mockLocalDataSource.clearAll()).called(1);
    });
  });

  group('isAuthenticated', () {
    test('should return true when access token exists', () async {
      // Arrange
      when(mockLocalDataSource.hasAccessToken()).thenAnswer((_) async => true);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when no access token', () async {
      // Arrange
      when(mockLocalDataSource.hasAccessToken()).thenAnswer((_) async => false);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, isFalse);
    });
  });
}