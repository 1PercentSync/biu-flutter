import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/space_acc_info.dart';
import '../models/space_arc_search.dart';
import '../models/space_relation.dart';

/// Remote data source for user profile API calls
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
