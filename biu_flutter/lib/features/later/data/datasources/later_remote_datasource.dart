import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/watch_later_item.dart';

/// Response from watch later list API
class WatchLaterListResponse {
  const WatchLaterListResponse({
    required this.count,
    required this.list,
  });

  factory WatchLaterListResponse.fromJson(Map<String, dynamic> json) {
    final listData = json['list'] as List<dynamic>?;

    return WatchLaterListResponse(
      count: json['count'] as int? ?? 0,
      list: listData
              ?.map((e) => WatchLaterItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final int count;
  final List<WatchLaterItem> list;
}

/// Remote data source for watch later API calls
///
/// Source: biu/src/service/history-toview-list.ts#getHistoryToviewList
/// Source: biu/src/service/history-toview-add.ts#postHistoryToviewAdd
/// Source: biu/src/service/history-toview-del.ts#postHistoryToviewDel
/// Source: biu/src/service/history-toview-clear.ts#postHistoryToviewClear
class LaterRemoteDataSource {
  LaterRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Default page size for watch later list
  static const int defaultPageSize = 20;

  /// Get watch later list with pagination
  /// GET /x/v2/history/toview/web
  ///
  /// [pn] - Page number, default 1
  /// [ps] - Page size, default 20, max 50
  /// [viewed] - Filter: 0 = all, 2 = not watched
  Future<WatchLaterListResponse> getWatchLaterList({
    int pn = 1,
    int ps = defaultPageSize,
    int viewed = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/v2/history/toview/web',
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'viewed': viewed,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch watch later list');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      // Handle specific error codes
      if (code == -101) {
        throw LaterNotLoggedInException();
      }
      throw Exception('API error: $message (code: $code)');
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const WatchLaterListResponse(count: 0, list: []);
    }

    return WatchLaterListResponse.fromJson(responseData);
  }

  /// Add video to watch later
  /// POST /x/v2/history/toview/add
  ///
  /// [aid] - Video aid (optional if bvid provided)
  /// [bvid] - Video bvid (optional if aid provided)
  Future<bool> addToWatchLater({
    int? aid,
    String? bvid,
  }) async {
    if (aid == null && (bvid == null || bvid.isEmpty)) {
      throw ArgumentError('Either aid or bvid must be provided');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/x/v2/history/toview/add',
      data: {
        if (aid != null) 'aid': aid,
        if (bvid != null && bvid.isNotEmpty) 'bvid': bvid,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        extra: {'useCSRF': true},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to add to watch later');
    }

    final code = data['code'] as int?;
    if (code == 0) {
      return true;
    }

    final message = data['message'] as String? ?? 'Unknown error';

    // Handle specific error codes
    switch (code) {
      case -101:
        throw LaterNotLoggedInException();
      case -111:
        throw Exception('CSRF verification failed');
      case 90001:
        throw LaterListFullException();
      case 90003:
        throw LaterVideoNotExistException();
      default:
        throw Exception('API error: $message (code: $code)');
    }
  }

  /// Remove video from watch later
  /// POST /x/v2/history/toview/del
  ///
  /// [aid] - Video aid to delete (optional)
  /// [viewed] - Delete all watched videos if true
  Future<bool> removeFromWatchLater({
    int? aid,
    bool viewed = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/x/v2/history/toview/del',
      data: {
        if (aid != null) 'aid': aid,
        if (viewed) 'viewed': viewed,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        extra: {'useCSRF': true},
      ),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to remove from watch later');
    }

    final code = data['code'] as int?;
    if (code == 0) {
      return true;
    }

    final message = data['message'] as String? ?? 'Unknown error';

    // Handle specific error codes
    switch (code) {
      case -101:
        throw LaterNotLoggedInException();
      case -111:
        throw Exception('CSRF verification failed');
      default:
        throw Exception('API error: $message (code: $code)');
    }
  }

  /// Clear all watched videos from watch later
  Future<bool> clearWatchedFromWatchLater() async {
    return removeFromWatchLater(viewed: true);
  }
}

/// Exception thrown when user is not logged in
class LaterNotLoggedInException implements Exception {
  @override
  String toString() => 'Not logged in';
}

/// Exception thrown when watch later list is full
class LaterListFullException implements Exception {
  @override
  String toString() => 'Watch later list is full (max 100 items)';
}

/// Exception thrown when video does not exist
class LaterVideoNotExistException implements Exception {
  @override
  String toString() => 'Video has been deleted';
}
