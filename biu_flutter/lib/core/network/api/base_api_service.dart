import 'package:dio/dio.dart';

import '../dio_client.dart';

/// Request options for Bilibili API
class BiliRequestOptions {
  const BiliRequestOptions({
    this.useWbi = false,
    this.useCSRF = false,
  });

  /// Whether to add WBI signature
  final bool useWbi;

  /// Whether to add CSRF token
  final bool useCSRF;

  /// Convert to Dio extra map
  Map<String, dynamic> toExtra() {
    return {
      'useWbi': useWbi,
      'useCSRF': useCSRF,
    };
  }
}

/// Base API service providing common HTTP methods
abstract class BaseApiService {
  BaseApiService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Make a GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    BiliRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: Options(extra: options?.toExtra()),
    );

    return _parseResponse<T>(response, fromJson);
  }

  /// Make a POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    BiliRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: options?.toExtra()),
    );

    return _parseResponse<T>(response, fromJson);
  }

  /// Parse response with optional fromJson converter
  T _parseResponse<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data;
    if (data == null) {
      throw Exception('Response data is null');
    }

    if (fromJson != null) {
      return fromJson(data);
    }

    return data as T;
  }
}

/// Standard Bilibili API response wrapper
class BiliResponse<T> {
  const BiliResponse({
    required this.code,
    required this.message,
    required this.ttl,
    this.data,
  });

  factory BiliResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataFromJson,
  ) {
    return BiliResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      ttl: json['ttl'] as int? ?? 1,
      data: dataFromJson != null && json['data'] != null
          ? dataFromJson(json['data'])
          : json['data'] as T?,
    );
  }

  final int code;
  final String message;
  final int ttl;
  final T? data;

  bool get isSuccess => code == 0;
}
