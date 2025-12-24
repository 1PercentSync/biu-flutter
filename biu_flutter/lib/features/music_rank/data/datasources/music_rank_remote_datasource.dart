import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/hot_song.dart';

/// Remote data source for music rank API calls
class MusicRankRemoteDataSource {
  MusicRankRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Get music hot rank list
  /// GET /x/centralization/interface/music/hot/rank
  ///
  /// [plat] - Platform type, 2 for web hot rank
  /// [webLocation] - Web location identifier, default "333.1351"
  Future<List<HotSong>> getMusicHotRank({
    int plat = 2,
    String webLocation = '333.1351',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/centralization/interface/music/hot/rank',
      queryParameters: {
        'plat': plat,
        'web_location': webLocation,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch music hot rank');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception('API error: $message (code: $code)');
    }

    final rankData = data['data'] as Map<String, dynamic>?;
    if (rankData == null) {
      throw Exception('Music rank data is null');
    }

    final list = rankData['list'] as List<dynamic>?;
    if (list == null) {
      return [];
    }

    return list
        .map((e) => HotSong.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
