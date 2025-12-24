/// Hot song item from music rank API
class HotSong {
  const HotSong({
    required this.id,
    required this.musicId,
    required this.musicTitle,
    required this.author,
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.cover,
    this.album,
    this.musicCorner,
    this.jumpUrl,
    this.totalVv,
    this.wishCount,
    this.source,
  });

  factory HotSong.fromJson(Map<String, dynamic> json) {
    return HotSong(
      id: json['id'] as int? ?? 0,
      musicId: json['music_id'] as String? ?? '',
      musicTitle: json['music_title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      bvid: json['bvid'] as String? ?? '',
      aid: json['aid'] as String? ?? '',
      cid: json['cid'] as String? ?? '',
      cover: _normalizeCoverUrl(json['cover'] as String? ?? ''),
      album: json['album'] as String?,
      musicCorner: json['music_corner'] as String?,
      jumpUrl: json['jump_url'] as String?,
      totalVv: json['total_vv'] as int?,
      wishCount: json['wish_count'] as int?,
      source: json['source'] as String?,
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
  final String? album;
  final String? musicCorner;
  final String? jumpUrl;
  final int? totalVv;
  final int? wishCount;
  final String? source;

  /// Get formatted play count
  String get playCountFormatted {
    if (totalVv == null) return '--';
    if (totalVv! >= 100000000) {
      return '${(totalVv! / 100000000).toStringAsFixed(1)}亿';
    }
    if (totalVv! >= 10000) {
      return '${(totalVv! / 10000).toStringAsFixed(1)}万';
    }
    return totalVv.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'music_id': musicId,
        'music_title': musicTitle,
        'author': author,
        'bvid': bvid,
        'aid': aid,
        'cid': cid,
        'cover': cover,
        'album': album,
        'music_corner': musicCorner,
        'jump_url': jumpUrl,
        'total_vv': totalVv,
        'wish_count': wishCount,
        'source': source,
      };

  /// Normalize cover URL (add https if missing)
  static String _normalizeCoverUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }
}
