import '../entities/user.dart';
import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<(User, AuthTokens)> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<(User, AuthTokens)> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
  });

  /// Logout current user
  Future<void> logout();

  /// Request password reset
  Future<void> forgotPassword(String email);

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Get current user from stored token
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Verify email with token
  Future<void> verifyEmail(String token);
}