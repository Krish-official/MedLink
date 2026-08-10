import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const String _userKey = 'user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthLocalDataSource(this._storage);

  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null;
  }
}