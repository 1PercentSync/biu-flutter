import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/musician.dart';

/// Remote data source for artist/musician rank API calls
class ArtistRankRemoteDataSource {
  ArtistRankRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Get musician list
  /// GET /x/centralization/interface/musician/list
  ///
  /// [levelSource] - Filter by level: 1 = all, 2 = new musicians
  Future<List<Musician>> getMusicianList({
    MusicianLevelSource levelSource = MusicianLevelSource.all,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/x/centralization/interface/musician/list',
      queryParameters: {
        'level_source': levelSource.value,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Failed to fetch musician list');
    }

    final code = data['code'] as int?;
    if (code != 0) {
      final message = data['message'] as String? ?? 'Unknown error';
      throw Exception('API error: $message (code: $code)');
    }

    final responseData = data['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      return [];
    }

    final musicians = responseData['musicians'] as List<dynamic>?;
    if (musicians == null) {
      return [];
    }

    return musicians
        .map((e) => Musician.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all musicians (famous + new)
  Future<List<Musician>> getAllMusicians() async {
    final results = await Future.wait([
      getMusicianList(levelSource: MusicianLevelSource.all),
      getMusicianList(levelSource: MusicianLevelSource.newMusicians),
    ]);

    return [...results[0], ...results[1]];
  }
}
