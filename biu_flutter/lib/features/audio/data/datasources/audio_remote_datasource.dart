import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/audio_stream.dart';

/// Remote data source for audio-related API calls
class AudioRemoteDataSource {
  AudioRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Get audio stream URL for music
  /// GET /audio/music-service-c/url
  ///
  /// [songId] - Audio song ID
  /// [quality] - Audio quality (2: 192kbps, 3: 320kbps/FLAC for VIP)
  /// [mid] - User mid (optional)
  Future<AudioStreamData> getAudioStreamUrl({
    required int songId,
    int quality = 2,
    int? mid,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/audio/music-service-c/url',
      queryParameters: {
        'songid': songId,
        'quality': quality,
        'privilege': 2,
        'platform': 'web',
        if (mid != null) 'mid': mid,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get audio stream URL');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      throw Exception(data['msg'] ?? 'Failed to get audio stream');
    }

    final audioData = data['data'] as Map<String, dynamic>?;
    if (audioData == null) {
      throw Exception('Audio data is null');
    }

    return AudioStreamData.fromJson(audioData);
  }

  /// Get audio info
  /// GET /audio/music-service-c/songs/playing
  Future<Map<String, dynamic>> getAudioInfo({required int songId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/audio/music-service-c/songs/playing',
      queryParameters: {
        'song_id': songId,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to get audio info');
    }

    return data['data'] as Map<String, dynamic>? ?? {};
  }
}

/// Audio quality constants
class AudioQuality {
  AudioQuality._();

  /// 128kbps
  static const int low = 0;

  /// 192kbps
  static const int normal = 1;

  /// 320kbps (requires VIP)
  static const int high = 2;

  /// FLAC (requires VIP)
  static const int lossless = 3;

  /// Get quality name
  static String getName(int quality) {
    switch (quality) {
      case low:
        return '128K';
      case normal:
        return '192K';
      case high:
        return '320K';
      case lossless:
        return 'FLAC';
      default:
        return 'Unknown';
    }
  }
}
