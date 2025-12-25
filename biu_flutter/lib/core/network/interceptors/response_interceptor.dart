import 'package:dio/dio.dart';

import '../../constants/api.dart';
import '../../errors/app_exception.dart';

/// Interceptor for handling Bilibili API response format.
///
/// Source: biu/src/service/request/response-interceptors.ts#geetestInterceptors
///
/// Bilibili APIs return responses in the format:
/// {
///   "code": 0,
///   "message": "0",
///   "ttl": 1,
///   "data": { ... }
/// }
///
/// This interceptor:
/// 1. Extracts the response body from the Dio response
/// 2. Checks the `code` field for API-level errors
/// 3. Throws [BilibiliApiException] if code != 0
class BiliResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // Skip processing if not a JSON response
    if (data == null || data is! Map<String, dynamic>) {
      handler.next(response);
      return;
    }

    // Check for Bilibili API error code
    final code = data['code'] as int?;
    if (code != null && code != ApiConstants.successCode) {
      final message = data['message'] as String? ?? 'Unknown error';

      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: BilibiliApiException(
            code: code,
            message: message,
            requestUrl: response.requestOptions.uri.toString(),
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    // Return the full response data (not just 'data' field)
    // Let the caller decide how to extract the data
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to more specific exceptions
    if (err.error is BilibiliApiException) {
      handler.next(err);
      return;
    }

    // Handle network errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: NetworkException(
              message: '请求超时',
              statusCode: err.response?.statusCode,
              url: err.requestOptions.uri.toString(),
            ),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: NetworkException(
              message: '连接错误: ${err.message}',
              url: err.requestOptions.uri.toString(),
            ),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: NetworkException(
              message: 'HTTP错误: $statusCode',
              statusCode: statusCode,
              url: err.requestOptions.uri.toString(),
            ),
            type: err.type,
          ),
        );
        return;
      default:
        handler.next(err);
    }
  }
}
