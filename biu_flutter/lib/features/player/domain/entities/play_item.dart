import 'package:biu_flutter/core/constants/audio.dart';

/// Represents a playable item in the playlist.
/// Maps to PlayData interface from the source project.
class PlayItem {

  const PlayItem({
    required this.id,
    required this.title,
    required this.type,
    this.bvid,
    this.sid,
    this.aid,
    this.cid,
    this.cover,
    this.ownerName,
    this.ownerMid,
    this.hasMultiPart = false,
    this.pageTitle,
    this.pageCover,
    this.pageIndex,
    this.totalPage,
    this.duration,
    this.audioUrl,
    this.videoUrl,
    this.isLossless = false,
    this.isDolby = false,
  });

  /// Create from JSON
  factory PlayItem.fromJson(Map<String, dynamic> json) {
    return PlayItem(
      id: json['id'] as String,
      title: json['title'] as String,
      type: PlayDataType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PlayDataType.mv,
      ),
      bvid: json['bvid'] as String?,
      sid: json['sid'] as int?,
      aid: json['aid'] as String?,
      cid: json['cid'] as String?,
      cover: json['cover'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerMid: json['ownerMid'] as int?,
      hasMultiPart: json['hasMultiPart'] as bool? ?? false,
      pageTitle: json['pageTitle'] as String?,
      pageCover: json['pageCover'] as String?,
      pageIndex: json['pageIndex'] as int?,
      totalPage: json['totalPage'] as int?,
      duration: json['duration'] as int?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isLossless: json['isLossless'] as bool? ?? false,
      isDolby: json['isDolby'] as bool? ?? false,
    );
  }
  /// Unique ID for this playlist entry
  final String id;

  /// Display title
  final String title;

  /// Content type (mv or audio)
  final PlayDataType type;

  /// Video BV ID (for mv type)
  final String? bvid;

  /// Audio song ID (for audio type)
  final int? sid;

  /// Video AV ID (needed for some operations like favorites)
  final String? aid;

  /// Video part CID
  final String? cid;

  /// Cover image URL
  final String? cover;

  /// UP (content creator) name
  final String? ownerName;

  /// UP member ID
  final int? ownerMid;

  /// Whether video has multiple parts
  final bool hasMultiPart;

  /// Part title (for multi-part videos)
  final String? pageTitle;

  /// Part cover image (for multi-part videos)
  final String? pageCover;

  /// Part index (1-based)
  final int? pageIndex;

  /// Total number of parts
  final int? totalPage;

  /// Duration in seconds
  final int? duration;

  /// Audio stream URL
  final String? audioUrl;

  /// Video stream URL
  final String? videoUrl;

  /// Whether audio is lossless quality
  final bool isLossless;

  /// Whether audio is Dolby
  final bool isDolby;

  /// Display title - uses pageTitle for multi-part videos, otherwise title
  String get displayTitle => pageTitle ?? title;

  /// Display cover - uses pageCover for multi-part videos, otherwise cover
  String? get displayCover => pageCover ?? cover;

  /// Check if this item matches another by content (same bvid or sid)
  bool isSameContent(PlayItem? other) {
    if (other == null || type != other.type) return false;
    if (type == PlayDataType.mv) {
      return bvid == other.bvid;
    }
    return sid == other.sid;
  }

  /// Create a copy with updated fields
  PlayItem copyWith({
    String? id,
    String? title,
    PlayDataType? type,
    String? bvid,
    int? sid,
    String? aid,
    String? cid,
    String? cover,
    String? ownerName,
    int? ownerMid,
    bool? hasMultiPart,
    String? pageTitle,
    String? pageCover,
    int? pageIndex,
    int? totalPage,
    int? duration,
    String? audioUrl,
    String? videoUrl,
    bool? isLossless,
    bool? isDolby,
  }) {
    return PlayItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      bvid: bvid ?? this.bvid,
      sid: sid ?? this.sid,
      aid: aid ?? this.aid,
      cid: cid ?? this.cid,
      cover: cover ?? this.cover,
      ownerName: ownerName ?? this.ownerName,
      ownerMid: ownerMid ?? this.ownerMid,
      hasMultiPart: hasMultiPart ?? this.hasMultiPart,
      pageTitle: pageTitle ?? this.pageTitle,
      pageCover: pageCover ?? this.pageCover,
      pageIndex: pageIndex ?? this.pageIndex,
      totalPage: totalPage ?? this.totalPage,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isLossless: isLossless ?? this.isLossless,
      isDolby: isDolby ?? this.isDolby,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'bvid': bvid,
      'sid': sid,
      'aid': aid,
      'cid': cid,
      'cover': cover,
      'ownerName': ownerName,
      'ownerMid': ownerMid,
      'hasMultiPart': hasMultiPart,
      'pageTitle': pageTitle,
      'pageCover': pageCover,
      'pageIndex': pageIndex,
      'totalPage': totalPage,
      'duration': duration,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'isLossless': isLossless,
      'isDolby': isDolby,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
