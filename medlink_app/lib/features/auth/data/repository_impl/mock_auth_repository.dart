import '../../domain/entities/user.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repository/auth_repository.dart';

/// Fake auth repository for testing UI/navigation without a backend.
/// Accepts ANY email/password and returns a fake user after a short delay.
class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<(User, AuthTokens)> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User(
      id: 'mock-user-1',
      email: email,
      firstName: 'Test',
      lastName: 'Patient',
      role: UserRole.patient, // change to .doctor or .admin to test other dashboards
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _currentUser = user;

    const tokens = AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh');
    return (user, tokens);
  }

  @override
  Future<(User, AuthTokens)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = User(
      id: 'mock-user-2',
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      phone: phone,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _currentUser = user;

    const tokens = AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh');
    return (user, tokens);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {}

  @override
  Future<User?> getCurrentUser() async {
    // Returning null here means the app starts on the login screen every launch.
    return null;
  }

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;

  @override
  Future<void> verifyEmail(String token) async {}
}