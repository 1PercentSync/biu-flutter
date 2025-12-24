import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/recommended_song.dart';

/// Remote data source for music recommend API calls
/// Source: biu/src/service/music-comprehensive-web-rank.ts#getMusicComprehensiveWebRank
class MusicRecommendRemoteDataSource {
  MusicRecommendRemoteDataSource({Dio? dio})
      : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Default page size
  static const int defaultPageSize = 20;

  /// Get music comprehensive rank list (recommended music)
  /// GET /x/centralization/interface/music/comprehensive/web/rank
  ///
  /// [pn] - Page number, starts from 1
  /// [ps] - Page size, default 20
  /// [webLocation] - Web location identifier, default "333.1351"
  Future<List<RecommendedSong>> getMusicRecommend({
    int pn = 1,
    int ps = defaultPageSize,
    String webLocation = '333.1351',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/centralization/interface/music/comprehensive/web/rank',
      queryParameters: {
        'pn': pn,
        'ps': ps,
        'web_location': webLocation,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch music recommend');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception('API error: $message (code: $code)');
    }

    final rankData = data['data'] as Map<String, dynamic>?;
    if (rankData == null) {
      throw Exception('Music recommend data is null');
    }

    final list = rankData['list'] as List<dynamic>?;
    if (list == null) {
      return [];
    }

    return list
        .map((e) => RecommendedSong.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
