import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/auth_response_dto.dart';
import '../../domain/entities/user.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }

  Future<void> forgotPassword(String email) async {
    await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  Future<User> getCurrentUser() async {
    final response = await _dioClient.get('/auth/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> verifyEmail(String token) async {
    await _dioClient.post(
      ApiEndpoints.verifyEmail,
      data: {'token': token},
    );
  }
}