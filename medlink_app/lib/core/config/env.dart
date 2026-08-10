import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;
  
  @EnviedField(varName: 'API_TIMEOUT')
  static const int apiTimeout = _Env.apiTimeout;
  
  @EnviedField(varName: 'ENABLE_LOGGING', defaultValue: true)
  static const bool enableLogging = _Env.enableLogging;
}