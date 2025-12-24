import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/video_info.dart';
import '../models/play_url.dart';

/// Remote data source for video-related API calls
class VideoRemoteDataSource {
  VideoRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Get video info by BVID
  /// GET /x/web-interface/view
  Future<VideoInfo> getVideoInfo({String? bvid, int? aid}) async {
    if (bvid == null && aid == null) {
      throw ArgumentError('Either bvid or aid must be provided');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/x/web-interface/view',
      queryParameters: {
        if (bvid != null) 'bvid': bvid,
        if (aid != null) 'aid': aid,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get video info');
    }

    final videoData = data['data'] as Map<String, dynamic>?;
    if (videoData == null) {
      throw Exception('Video data is null');
    }

    return VideoInfo.fromJson(videoData);
  }

  /// Get video play URL (DASH format)
  /// GET /x/player/wbi/playurl
  ///
  /// [bvid] - Video BVID
  /// [cid] - Video CID (part)
  /// [qn] - Quality number (default 80 for 1080p)
  /// [fnval] - Format value (16 for DASH)
  /// [fourk] - Enable 4K (1 = enabled)
  Future<PlayUrlData> getPlayUrl({
    required String bvid,
    required int cid,
    int qn = 80,
    int fnval = 16,
    int fourk = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/player/wbi/playurl',
      queryParameters: {
        'bvid': bvid,
        'cid': cid,
        'qn': qn,
        'fnval': fnval,
        'fourk': fourk,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get play URL');
    }

    final playData = data['data'] as Map<String, dynamic>?;
    if (playData == null) {
      throw Exception('Play URL data is null');
    }

    return PlayUrlData.fromJson(playData);
  }

  /// Get video play URL by AID
  Future<PlayUrlData> getPlayUrlByAid({
    required int aid,
    required int cid,
    int qn = 80,
    int fnval = 16,
    int fourk = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/player/wbi/playurl',
      queryParameters: {
        'avid': aid,
        'cid': cid,
        'qn': qn,
        'fnval': fnval,
        'fourk': fourk,
      },
      options: Options(extra: {'useWbi': true}),
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get play URL');
    }

    final playData = data['data'] as Map<String, dynamic>?;
    if (playData == null) {
      throw Exception('Play URL data is null');
    }

    return PlayUrlData.fromJson(playData);
  }
}
