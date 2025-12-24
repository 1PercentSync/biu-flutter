import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/history_item.dart';

/// Response from history cursor API
class HistoryCursorResponse {
  const HistoryCursorResponse({
    required this.cursor,
    required this.list,
    this.tab,
  });

  factory HistoryCursorResponse.fromJson(Map<String, dynamic> json) {
    final cursorData = json['cursor'] as Map<String, dynamic>?;
    final listData = json['list'] as List<dynamic>?;

    return HistoryCursorResponse(
      cursor: cursorData != null
          ? HistoryCursorInfo.fromJson(cursorData)
          : const HistoryCursorInfo(max: 0, viewAt: 0, business: '', ps: 20),
      list: listData
              ?.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tab: (json['tab'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  final HistoryCursorInfo cursor;
  final List<HistoryItem> list;
  final List<Map<String, dynamic>>? tab;

  bool get hasMore => list.isNotEmpty;
}

/// Remote data source for history API calls
///
/// Source: biu/src/service/web-interface-history-cursor.ts#getWebInterfaceHistoryCursor
class HistoryRemoteDataSource {
  HistoryRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Default page size for history list
  static const int defaultPageSize = 30;

  /// Get watch history with cursor-based pagination
  /// GET /x/web-interface/history/cursor
  ///
  /// [max] - Cursor: target id of last item, default 0
  /// [business] - Cursor: business type of last item
  /// [viewAt] - Cursor: view_at of last item, default 0 (current time)
  /// [type] - Filter type: all, archive, live, article
  /// [ps] - Page size, 1-30, default 20
  Future<HistoryCursorResponse> getHistoryCursor({
    int max = 0,
    String? business,
    int viewAt = 0,
    HistoryFilterType type = HistoryFilterType.archive,
    int ps = defaultPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/history/cursor',
      queryParameters: {
        'max': max,
        if (business != null && business.isNotEmpty) 'business': business,
        'view_at': viewAt,
        'type': type.toApiString(),
        'ps': ps,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch history');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';

      // Handle specific error codes
      if (code == -101) {
        throw HistoryNotLoggedInException();
      }
      throw Exception('API error: $message (code: $code)');
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return const HistoryCursorResponse(
        cursor: HistoryCursorInfo(max: 0, viewAt: 0, business: '', ps: 20),
        list: [],
      );
    }

    return HistoryCursorResponse.fromJson(responseData);
  }
}

/// Exception thrown when user is not logged in
class HistoryNotLoggedInException implements Exception {
  @override
  String toString() => 'Not logged in';
}
