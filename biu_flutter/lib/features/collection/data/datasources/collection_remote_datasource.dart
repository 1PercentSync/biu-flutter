import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/video_series_detail.dart';

/// Remote datasource for collection-related API calls
/// Source: biu/src/service/user-video-archives-list.ts
class CollectionRemoteDatasource {
  CollectionRemoteDatasource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Fetch video series (seasons_archives) detail
  ///
  /// GET /x/space/fav/season/list
  ///
  /// [seasonId] - Video series/season ID (required)
  ///
  /// Source: biu/src/service/user-video-archives-list.ts:67-74
  Future<VideoSeriesDetailResponse> getVideoSeriesDetail({
    required int seasonId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/space/fav/season/list',
      queryParameters: {
        'season_id': seasonId,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch video series detail');
    }

    return VideoSeriesDetailResponse.fromJson(data);
  }
}
