import '../../domain/entities/user.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<(User, AuthTokens)> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestDto(email: email, password: password);
    final response = await _remoteDataSource.login(request);

    // Save tokens and user locally
    await _localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localDataSource.saveUser(response.user);

    final tokens = AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return (response.user, tokens);
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
    final request = RegisterRequestDto(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role.name,
      phone: phone,
    );

    final response = await _remoteDataSource.register(request);

    // Save tokens and user locally
    await _localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _localDataSource.saveUser(response.user);

    final tokens = AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return (response.user, tokens);
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      // Even if remote logout fails, clear local data
    } finally {
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    // First try to get from local storage
    final localUser = await _localDataSource.getUser();
    if (localUser != null) return localUser;

    // If not in local storage but has token, fetch from API
    final hasToken = await _localDataSource.hasAccessToken();
    if (hasToken) {
      try {
        final user = await _remoteDataSource.getCurrentUser();
        await _localDataSource.saveUser(user);
        return user;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.hasAccessToken();
  }

  @override
  Future<void> verifyEmail(String token) async {
    await _remoteDataSource.verifyEmail(token);
  }
}