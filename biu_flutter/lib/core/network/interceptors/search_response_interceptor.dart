import 'dart:convert';

import 'package:dio/dio.dart';

/// Response interceptor for search API (s.search.bilibili.com).
///
/// Source: biu/src/service/request/index.ts:42
/// searchRequest.interceptors.response.use(res => res.data);
///
/// The search API may return responses with Content-Type that Dio doesn't
/// automatically parse as JSON. This interceptor ensures JSON responses
/// are properly decoded.
class SearchResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // If response is already a Map, pass through
    if (data is Map<String, dynamic>) {
      handler.next(response);
      return;
    }

    // If response is a String, try to parse as JSON
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        response.data = decoded;
      } catch (_) {
        // If parsing fails, keep original data
      }
    }

    handler.next(response);
  }
}
