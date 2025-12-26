import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../user_profile/data/models/dynamic_item.dart';

/// Remote data source for dynamic feed API calls.
///
/// Fetches dynamics from followed users (全站动态).
/// Source: biu/src/service/web-dynamic.ts#getWebDynamicFeedAll
class DynamicFeedRemoteDataSource {
  DynamicFeedRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Fetch all dynamics from followed users (登录用户关注的UP主动态)
  /// GET /x/polymer/web-dynamic/v1/feed/all
  ///
  /// [type] - Dynamic type filter: "all", "video", "pgc", "article"
  /// [offset] - Pagination offset cursor (optional, for loading more)
  /// [updateBaseline] - Baseline for checking new dynamics
  /// [timezoneOffset] - Timezone offset in minutes (default: -480 for UTC+8)
  ///
  /// Source: biu/src/service/web-dynamic.ts#getWebDynamicFeedAll
  Future<DynamicFeedResponse> getDynamicFeedAll({
    String type = 'video',
    String? offset,
    String? updateBaseline,
    int timezoneOffset = -480,
    String platform = 'web',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/polymer/web-dynamic/v1/feed/all',
      queryParameters: {
        'type': type,
        if (offset != null && offset.isNotEmpty) 'offset': offset,
        if (updateBaseline != null && updateBaseline.isNotEmpty)
          'update_baseline': updateBaseline,
        'timezone_offset': timezoneOffset,
        'platform': platform,
      },
    );

    final data = response.data;
    if (data == null) {
      throw DynamicFeedException('Failed to fetch dynamic feed');
    }

    return DynamicFeedResponse.fromJson(data);
  }

  /// Check for new dynamics since last update
  /// GET /x/polymer/web-dynamic/v1/feed/all/update
  ///
  /// [updateBaseline] - Update baseline from previous response
  /// [timezoneOffset] - Timezone offset in minutes
  ///
  /// Source: biu/src/service/web-dynamic.ts#getWebDynamicFeedAllUpdate
  Future<DynamicFeedResponse> checkDynamicUpdate({
    required String updateBaseline,
    int timezoneOffset = -480,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/polymer/web-dynamic/v1/feed/all/update',
      queryParameters: {
        'update_baseline': updateBaseline,
        'timezone_offset': timezoneOffset,
      },
    );

    final data = response.data;
    if (data == null) {
      throw DynamicFeedException('Failed to check dynamic update');
    }

    return DynamicFeedResponse.fromJson(data);
  }
}

/// Exception for dynamic feed errors
class DynamicFeedException implements Exception {
  DynamicFeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
