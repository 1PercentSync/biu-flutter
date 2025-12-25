// Video series detail models
// Source: biu/src/service/user-video-archives-list.ts

/// Upper (creator) info
class SeriesUpper {
  const SeriesUpper({
    required this.mid,
    required this.name,
  });

  factory SeriesUpper.fromJson(Map<String, dynamic> json) {
    return SeriesUpper(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  final int mid;
  final String name;
}

/// Count info for video series and media items
class SeriesCntInfo {
  const SeriesCntInfo({
    required this.collect,
    required this.play,
    required this.danmaku,
    this.vt = 0,
  });

  factory SeriesCntInfo.fromJson(Map<String, dynamic> json) {
    return SeriesCntInfo(
      collect: json['collect'] as int? ?? 0,
      play: json['play'] as int? ?? 0,
      danmaku: json['danmaku'] as int? ?? 0,
      vt: json['vt'] as int? ?? 0,
    );
  }

  final int collect;
  final int play;
  final int danmaku;
  final int vt;
}

/// Video series info
class VideoSeriesInfo {
  const VideoSeriesInfo({
    required this.id,
    required this.seasonType,
    required this.title,
    required this.cover,
    required this.upper,
    required this.cntInfo,
    required this.mediaCount,
    this.intro = '',
    this.enableVt = 0,
  });

  factory VideoSeriesInfo.fromJson(Map<String, dynamic> json) {
    return VideoSeriesInfo(
      id: json['id'] as int? ?? 0,
      seasonType: json['season_type'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      upper: json['upper'] != null
          ? SeriesUpper.fromJson(json['upper'] as Map<String, dynamic>)
          : const SeriesUpper(mid: 0, name: ''),
      cntInfo: json['cnt_info'] != null
          ? SeriesCntInfo.fromJson(json['cnt_info'] as Map<String, dynamic>)
          : const SeriesCntInfo(collect: 0, play: 0, danmaku: 0),
      mediaCount: json['media_count'] as int? ?? 0,
      intro: json['intro'] as String? ?? '',
      enableVt: json['enable_vt'] as int? ?? 0,
    );
  }

  final int id;
  final int seasonType;
  final String title;
  final String cover;
  final SeriesUpper upper;
  final SeriesCntInfo cntInfo;
  final int mediaCount;
  final String intro;
  final int enableVt;
}

/// Media item in video series
class SeriesMediaItem {
  const SeriesMediaItem({
    required this.id,
    required this.title,
    required this.cover,
    required this.duration,
    required this.pubtime,
    required this.bvid,
    required this.upper,
    required this.cntInfo,
    this.enableVt = 0,
    this.vtDisplay = '',
    this.isSelfView = false,
  });

  factory SeriesMediaItem.fromJson(Map<String, dynamic> json) {
    return SeriesMediaItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      pubtime: json['pubtime'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      upper: json['upper'] != null
          ? SeriesUpper.fromJson(json['upper'] as Map<String, dynamic>)
          : const SeriesUpper(mid: 0, name: ''),
      cntInfo: json['cnt_info'] != null
          ? SeriesCntInfo.fromJson(json['cnt_info'] as Map<String, dynamic>)
          : const SeriesCntInfo(collect: 0, play: 0, danmaku: 0),
      enableVt: json['enable_vt'] as int? ?? 0,
      vtDisplay: json['vt_display'] as String? ?? '',
      isSelfView: json['is_self_view'] as bool? ?? false,
    );
  }

  final int id;
  final String title;
  final String cover;
  final int duration;
  final int pubtime;
  final String bvid;
  final SeriesUpper upper;
  final SeriesCntInfo cntInfo;
  final int enableVt;
  final String vtDisplay;
  final bool isSelfView;

  /// Get publish date as DateTime
  DateTime get publishDate =>
      DateTime.fromMillisecondsSinceEpoch(pubtime * 1000);

  /// Get formatted duration string (MM:SS or HH:MM:SS)
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Video series detail data
class VideoSeriesDetailData {
  const VideoSeriesDetailData({
    required this.info,
    required this.medias,
  });

  factory VideoSeriesDetailData.fromJson(Map<String, dynamic> json) {
    return VideoSeriesDetailData(
      info: json['info'] != null
          ? VideoSeriesInfo.fromJson(json['info'] as Map<String, dynamic>)
          : const VideoSeriesInfo(
              id: 0,
              seasonType: 0,
              title: '',
              cover: '',
              upper: SeriesUpper(mid: 0, name: ''),
              cntInfo: SeriesCntInfo(collect: 0, play: 0, danmaku: 0),
              mediaCount: 0,
            ),
      medias: (json['medias'] as List<dynamic>?)
              ?.map((e) => SeriesMediaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final VideoSeriesInfo info;
  final List<SeriesMediaItem> medias;
}

/// Video series detail API response
/// GET /x/space/fav/season/list
class VideoSeriesDetailResponse {
  const VideoSeriesDetailResponse({
    required this.code,
    required this.message,
    this.ttl = 1,
    this.data,
  });

  factory VideoSeriesDetailResponse.fromJson(Map<String, dynamic> json) {
    return VideoSeriesDetailResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      ttl: json['ttl'] as int? ?? 1,
      data: json['data'] != null
          ? VideoSeriesDetailData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final int code;
  final String message;
  final int ttl;
  final VideoSeriesDetailData? data;

  bool get isSuccess => code == 0;
}
