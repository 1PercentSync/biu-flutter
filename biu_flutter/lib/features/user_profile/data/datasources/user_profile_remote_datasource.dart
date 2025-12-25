import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/dynamic_item.dart';
import '../models/space_acc_info.dart';
import '../models/space_arc_search.dart';
import '../models/space_relation.dart';
import '../models/space_setting.dart';
import '../models/video_series.dart';

/// Remote data source for user profile API calls
///
/// Source: biu/src/service/space-wbi-acc-info.ts#getSpaceWbiAccInfo
/// Source: biu/src/service/space-wbi-acc-relation.ts#getSpaceWbiAccRelation
/// Source: biu/src/service/space-wbi-arc-search.ts#getSpaceWbiArcSearch
/// Source: biu/src/service/relation-stat.ts#getRelationStat
/// Source: biu/src/service/space-setting.ts#getXSpaceSettings
/// Source: biu/src/service/space-seasons-series-list.ts#getSpaceSeasonsSeriesList
/// Source: biu/src/service/web-dynamic.ts#getWebDynamicFeedSpace
class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Default page size for videos
  static const int defaultPageSize = 20;

  /// Get user space detailed info
  /// GET /x/space/wbi/acc/info
  ///
  /// [mid] - Target user mid (required)
  Future<SpaceAccInfo> getSpaceAccInfo({required int mid}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/space/wbi/acc/info',
      queryParameters: {'mid': mid},
      options: Options(
        extra: {'useWbi': true},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch space info');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      switch (code) {
        case -400:
          throw SpaceRequestException('Request error');
        case -403:
          throw SpaceAccessDeniedException();
        case -404:
          throw SpaceUserNotFoundException();
        default:
          throw Exception('API error: $message (code: $code)');
      }
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Empty response data');
    }

    return SpaceAccInfo.fromJson(responseData);
  }

  /// Get user relation with current user
  /// GET /x/space/wbi/acc/relation
  ///
  /// [mid] - Target user mid (required)
  /// Requires login
  Future<SpaceRelationData> getSpaceRelation({required int mid}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/space/wbi/acc/relation',
      queryParameters: {'mid': mid},
      options: Options(
        extra: {'useWbi': true},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch relation');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      switch (code) {
        case -101:
          throw SpaceNotLoggedInException();
        case -400:
          throw SpaceRequestException('Request error');
        default:
          throw Exception('API error: $message (code: $code)');
      }
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const SpaceRelationData(
        relation: RelationAttribute(mid: 0, attribute: 0, mtime: 0),
        beRelation: RelationAttribute(mid: 0, attribute: 0, mtime: 0),
      );
    }

    return SpaceRelationData.fromJson(responseData);
  }

  /// Get relation statistics
  /// GET /x/relation/stat
  ///
  /// [vmid] - Target user mid (required)
  Future<RelationStat> getRelationStat({required int vmid}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/relation/stat',
      queryParameters: {'vmid': vmid},
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch relation stat');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception('API error: $message (code: $code)');
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const RelationStat(mid: 0, following: 0, follower: 0);
    }

    return RelationStat.fromJson(responseData);
  }

  /// Get user videos
  /// GET /x/space/wbi/arc/search
  ///
  /// [mid] - Target user mid (required)
  /// [pn] - Page number (starting from 1)
  /// [ps] - Page size (max 30)
  /// [tid] - Category tid (optional)
  /// [keyword] - Search keyword (optional)
  /// [order] - Sort order: "pubdate" (default), "click", "stow"
  Future<SpaceArcSearchData> getSpaceVideos({
    required int mid,
    int pn = 1,
    int ps = defaultPageSize,
    int? tid,
    String? keyword,
    String order = 'pubdate',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/space/wbi/arc/search',
      queryParameters: {
        'mid': mid,
        'pn': pn,
        'ps': ps,
        if (tid != null) 'tid': tid,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        'order': order,
      },
      options: Options(
        extra: {'useWbi': true},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch space videos');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      switch (code) {
        case -352:
          throw SpaceRequestBlockedException();
        case -400:
          throw SpaceRequestException('Request error');
        default:
          throw Exception('API error: $message (code: $code)');
      }
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const SpaceArcSearchData(
        list: SpaceArcSearchList(vlist: []),
        page: SpaceArcSearchPage(pn: 1, ps: 30, count: 0),
      );
    }

    return SpaceArcSearchData.fromJson(responseData);
  }

  /// Get user space privacy settings
  /// GET /x/space/setting
  ///
  /// [mid] - Target user mid (required)
  /// Source: biu/src/service/space-setting.ts#getXSpaceSettings
  Future<SpacePrivacy> getSpaceSetting({required int mid}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/space/setting',
      queryParameters: {
        'mid': mid,
        'web_location': '333.1387',
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch space settings');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception('API error: $message (code: $code)');
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const SpacePrivacy();
    }

    final privacy = responseData['privacy'] as Map<String, dynamic>?;
    if (privacy == null) {
      return const SpacePrivacy();
    }

    return SpacePrivacy.fromJson(privacy);
  }

  /// Fetch user's video series (seasons) list
  /// GET /x/polymer/web-space/seasons_series_list
  ///
  /// [mid] - Target user mid (required)
  /// [pageNum] - Page number (1-based, default: 1)
  /// [pageSize] - Page size (default: 20)
  ///
  /// Source: biu/src/service/space-seasons-series-list.ts
  Future<SeasonsSeriesListResponse> getSeasonsSeriesList({
    required int mid,
    int pageNum = 1,
    int pageSize = defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/polymer/web-space/seasons_series_list',
      queryParameters: {
        'mid': mid,
        'page_num': pageNum,
        'page_size': pageSize,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch seasons series list');
    }

    return SeasonsSeriesListResponse.fromJson(data);
  }

  /// Fetch user dynamic feed
  /// GET /x/polymer/web-dynamic/v1/feed/space
  ///
  /// [hostMid] - Target user mid (required)
  /// [offset] - Pagination offset cursor (optional, for loading more)
  /// [timezoneOffset] - Timezone offset in minutes (default: -480 for UTC+8)
  ///
  /// Source: biu/src/service/web-dynamic.ts#getWebDynamicFeedSpace
  Future<DynamicFeedResponse> getDynamicFeed({
    required int hostMid,
    String? offset,
    int timezoneOffset = -480,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/polymer/web-dynamic/v1/feed/space',
      queryParameters: {
        'host_mid': hostMid,
        if (offset != null && offset.isNotEmpty) 'offset': offset,
        'timezone_offset': timezoneOffset,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch dynamic feed');
    }

    return DynamicFeedResponse.fromJson(data);
  }

  /// Like or unlike a dynamic
  /// POST /x/dynamic/feed/dyn/thumb
  ///
  /// [dynIdStr] - Dynamic ID string
  /// [like] - true to like, false to unlike
  ///
  /// API params (from source):
  /// - dyn_id_str: Dynamic ID string (body)
  /// - up: 1 for like, 2 for unlike (body)
  /// - csrf: CSRF token (query param, NOT body - different from other APIs!)
  ///
  /// Source: biu/src/service/web-dynamic-feed-thumb.ts#postDynamicFeedThumb
  Future<bool> likeDynamic({
    required String dynIdStr,
    required bool like,
  }) async {
    // Get CSRF token for query param (source project puts csrf in params, not body)
    final csrfToken = await DioClient.instance.getCookie('bili_jct');

    // Source project uses axios default which sends JSON, not form-urlencoded
    final response = await _dio.post<Map<String, dynamic>>(
      '/x/dynamic/feed/dyn/thumb',
      data: {
        'dyn_id_str': dynIdStr,
        'up': like ? 1 : 2, // 1: like, 2: unlike
      },
      queryParameters: {
        if (csrfToken != null) 'csrf': csrfToken,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to like dynamic');
    }

    final code = data['code'] as int?;
    if (code == 0) {
      return true;
    }

    final message = data['message'] as String? ?? 'Unknown error';
    throw Exception('Failed to like: $message (code: $code)');
  }
}

/// Exception thrown when not logged in
class SpaceNotLoggedInException implements Exception {
  @override
  String toString() => 'Not logged in';
}

/// Exception thrown when user not found
class SpaceUserNotFoundException implements Exception {
  @override
  String toString() => 'User not found';
}

/// Exception thrown when access denied
class SpaceAccessDeniedException implements Exception {
  @override
  String toString() => 'Access denied';
}

/// Exception thrown for request errors
class SpaceRequestException implements Exception {
  SpaceRequestException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when request is blocked
class SpaceRequestBlockedException implements Exception {
  @override
  String toString() => 'Request blocked by risk control';
}
