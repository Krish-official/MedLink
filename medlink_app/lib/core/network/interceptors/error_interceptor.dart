import 'package:dio/dio.dart';
import '../api_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiError.fromDioException(err);
    
    // You can add global error handling here (e.g., show toast)
    // For now, just pass the transformed error forward
    
    handler.next(err);
  }
}