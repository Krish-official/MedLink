import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';

@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({
    required String message,
    required int statusCode,
    String? errorCode,
    Map<String, dynamic>? data,
  }) = _ApiError;

  factory ApiError.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode ?? 500;
        final data = exception.response?.data;

        String message = 'An error occurred';
        String? errorCode;

        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? message;
          errorCode = data['errorCode'] as String?;
        }

        return ApiError(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
          data: data is Map<String, dynamic> ? data : null,
        );

      case DioExceptionType.cancel:
        return const ApiError(
          message: 'Request cancelled',
          statusCode: 499,
        );

      case DioExceptionType.connectionError:
        return const ApiError(
          message: 'No internet connection',
          statusCode: 503,
        );

      case DioExceptionType.badCertificate:
        return const ApiError(
          message: 'Certificate verification failed',
          statusCode: 495,
        );

      case DioExceptionType.unknown:
      default:
        return const ApiError(
          message: 'An unexpected error occurred',
          statusCode: 500,
        );
    }
  }
}