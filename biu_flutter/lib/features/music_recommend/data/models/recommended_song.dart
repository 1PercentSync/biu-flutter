/// Related archive info for recommended song
/// Source: biu/src/service/music-comprehensive-web-rank.ts#RelatedArchive
class RelatedArchive {
  const RelatedArchive({
    required this.aid,
    required this.bvid,
    required this.cid,
    required this.cover,
    required this.title,
    required this.uid,
    required this.username,
    required this.vvCount,
    this.vtDisplay,
    this.isVt,
    this.fname,
    this.duration,
  });

  factory RelatedArchive.fromJson(Map<String, dynamic> json) {
    return RelatedArchive(
      aid: json['aid'] as String? ?? '',
      bvid: json['bvid'] as String? ?? '',
      cid: json['cid'] as String? ?? '',
      cover: _normalizeCoverUrl(json['cover'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      uid: json['uid'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      vvCount: json['vv_count'] as int? ?? 0,
      vtDisplay: json['vt_display'] as String?,
      isVt: json['is_vt'] as int?,
      fname: json['fname'] as String?,
      duration: json['duration'] as int?,
    );
  }

  final String aid;
  final String bvid;
  final String cid;
  final String cover;
  final String title;
  final int uid;
  final String username;
  final int vvCount;
  final String? vtDisplay;
  final int? isVt;
  final String? fname;
  final int? duration;

  static String _normalizeCoverUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }
}

/// Recommended song item from music comprehensive rank API
/// Source: biu/src/service/music-comprehensive-web-rank.ts#Data
class RecommendedSong {
  const RecommendedSong({
    required this.id,
    required this.musicId,
    required this.musicTitle,
    required this.author,
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.cover,
    required this.relatedArchive,
    this.album,
    this.musicCorner,
    this.jumpUrl,
    this.score,
  });

  factory RecommendedSong.fromJson(Map<String, dynamic> json) {
    final relatedArchiveJson = json['related_archive'] as Map<String, dynamic>?;

    return RecommendedSong(
      id: json['id'] as int? ?? 0,
      musicId: json['music_id'] as String? ?? '',
      musicTitle: json['music_title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      bvid: json['bvid'] as String? ?? '',
      aid: json['aid'] as String? ?? '',
      cid: json['cid'] as String? ?? '',
      cover: _normalizeCoverUrl(json['cover'] as String? ?? ''),
      relatedArchive: relatedArchiveJson != null
          ? RelatedArchive.fromJson(relatedArchiveJson)
          : null,
      album: json['album'] as String?,
      musicCorner: json['music_corner'] as String?,
      jumpUrl: json['jump_url'] as String?,
      score: json['score'] as int?,
    );
  }

  final int id;
  final String musicId;
  final String musicTitle;
  final String author;
  final String bvid;
  final String aid;
  final String cid;
  final String cover;
  final RelatedArchive? relatedArchive;
  final String? album;
  final String? musicCorner;
  final String? jumpUrl;
  final int? score;

  /// Get play count from related archive
  int get playCount => relatedArchive?.vvCount ?? 0;

  /// Get formatted play count
  String get playCountFormatted {
    final count = playCount;
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    }
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  /// Normalize cover URL (add https if missing)
  static String _normalizeCoverUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }
}
