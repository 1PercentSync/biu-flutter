/// Represents a media item in a favorites folder.
class FavMedia {
  const FavMedia({
    required this.id,
    required this.type,
    required this.title,
    required this.cover,
    required this.upper,
    required this.duration,
    this.intro = '',
    this.page = 1,
    this.attr = 0,
    this.ctime = 0,
    this.pubtime = 0,
    this.favTime = 0,
    this.bvid = '',
    this.playCount = 0,
    this.danmakuCount = 0,
    this.collectCount = 0,
  });

  /// Content id (video avid, audio auid, or collection id)
  final int id;

  /// Content type (2: video, 12: audio, 21: video collection)
  final int type;

  /// Content title
  final String title;

  /// Cover image URL
  final String cover;

  /// Uploader info
  final MediaUpper upper;

  /// Duration in seconds
  final int duration;

  /// Content description
  final String intro;

  /// Video page count
  final int page;

  /// Attribute (0: normal, 9: deleted by uploader, 1: deleted for other reasons)
  final int attr;

  /// Upload timestamp
  final int ctime;

  /// Publish timestamp
  final int pubtime;

  /// Favorite timestamp
  final int favTime;

  /// Video bvid
  final String bvid;

  /// Play count
  final int playCount;

  /// Danmaku count
  final int danmakuCount;

  /// Collect count
  final int collectCount;

  /// Whether this item is invalid/deleted
  bool get isInvalid => attr != 0;

  /// Whether this is a video
  bool get isVideo => type == 2;

  /// Whether this is an audio
  bool get isAudio => type == 12;

  /// Whether this is a video collection
  bool get isCollection => type == 21;

  FavMedia copyWith({
    int? id,
    int? type,
    String? title,
    String? cover,
    MediaUpper? upper,
    int? duration,
    String? intro,
    int? page,
    int? attr,
    int? ctime,
    int? pubtime,
    int? favTime,
    String? bvid,
    int? playCount,
    int? danmakuCount,
    int? collectCount,
  }) {
    return FavMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      upper: upper ?? this.upper,
      duration: duration ?? this.duration,
      intro: intro ?? this.intro,
      page: page ?? this.page,
      attr: attr ?? this.attr,
      ctime: ctime ?? this.ctime,
      pubtime: pubtime ?? this.pubtime,
      favTime: favTime ?? this.favTime,
      bvid: bvid ?? this.bvid,
      playCount: playCount ?? this.playCount,
      danmakuCount: danmakuCount ?? this.danmakuCount,
      collectCount: collectCount ?? this.collectCount,
    );
  }
}

/// Media uploader info
class MediaUpper {
  const MediaUpper({
    required this.mid,
    required this.name,
    this.face = '',
  });

  /// Uploader mid
  final int mid;

  /// Uploader name
  final String name;

  /// Uploader avatar URL
  final String face;

  MediaUpper copyWith({
    int? mid,
    String? name,
    String? face,
  }) {
    return MediaUpper(
      mid: mid ?? this.mid,
      name: name ?? this.name,
      face: face ?? this.face,
    );
  }
}
