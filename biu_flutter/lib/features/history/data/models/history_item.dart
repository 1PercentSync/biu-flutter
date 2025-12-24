/// Business type for history items
enum HistoryBusinessType {
  archive,
  pgc,
  live,
  articleList,
  article;

  factory HistoryBusinessType.fromString(String value) {
    switch (value) {
      case 'archive':
        return HistoryBusinessType.archive;
      case 'pgc':
        return HistoryBusinessType.pgc;
      case 'live':
        return HistoryBusinessType.live;
      case 'article-list':
        return HistoryBusinessType.articleList;
      case 'article':
        return HistoryBusinessType.article;
      default:
        return HistoryBusinessType.archive;
    }
  }

  String toApiString() {
    switch (this) {
      case HistoryBusinessType.archive:
        return 'archive';
      case HistoryBusinessType.pgc:
        return 'pgc';
      case HistoryBusinessType.live:
        return 'live';
      case HistoryBusinessType.articleList:
        return 'article-list';
      case HistoryBusinessType.article:
        return 'article';
    }
  }
}

/// Filter type for history queries
enum HistoryFilterType {
  all,
  archive,
  live,
  article;

  String toApiString() {
    return name;
  }
}

/// Cursor info for pagination
class HistoryCursorInfo {
  const HistoryCursorInfo({
    required this.max,
    required this.viewAt,
    required this.business,
    required this.ps,
  });

  factory HistoryCursorInfo.fromJson(Map<String, dynamic> json) {
    return HistoryCursorInfo(
      max: json['max'] as int? ?? 0,
      viewAt: json['view_at'] as int? ?? 0,
      business: json['business'] as String? ?? '',
      ps: json['ps'] as int? ?? 20,
    );
  }

  final int max;
  final int viewAt;
  final String business;
  final int ps;

  Map<String, dynamic> toJson() => {
        'max': max,
        'view_at': viewAt,
        'business': business,
        'ps': ps,
      };
}

/// History detail info
class HistoryDetail {
  const HistoryDetail({
    required this.oid,
    required this.business,
    this.epid,
    this.bvid,
    this.page,
    this.cid,
    this.part,
    this.dt,
  });

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    return HistoryDetail(
      oid: json['oid'] as int? ?? 0,
      business: json['business'] as String? ?? 'archive',
      epid: json['epid'] as int?,
      bvid: json['bvid'] as String?,
      page: json['page'] as int?,
      cid: json['cid'] as int?,
      part: json['part'] as String?,
      dt: json['dt'] as int?,
    );
  }

  final int oid;
  final String business;
  final int? epid;
  final String? bvid;
  final int? page;
  final int? cid;
  final String? part;
  final int? dt;

  Map<String, dynamic> toJson() => {
        'oid': oid,
        'business': business,
        if (epid != null) 'epid': epid,
        if (bvid != null) 'bvid': bvid,
        if (page != null) 'page': page,
        if (cid != null) 'cid': cid,
        if (part != null) 'part': part,
        if (dt != null) 'dt': dt,
      };
}

/// History list item
class HistoryItem {
  const HistoryItem({
    required this.title,
    required this.cover,
    required this.history,
    required this.viewAt,
    this.longTitle,
    this.covers,
    this.uri,
    this.videos,
    this.authorName,
    this.authorFace,
    this.authorMid,
    this.progress,
    this.badge,
    this.showTitle,
    this.duration,
    this.current,
    this.total,
    this.newDesc,
    this.isFinish,
    this.isFav,
    this.kid,
    this.tagName,
    this.liveStatus,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      title: json['title'] as String? ?? '',
      longTitle: json['long_title'] as String?,
      cover: _normalizeCoverUrl(json['cover'] as String? ?? ''),
      covers: (json['covers'] as List<dynamic>?)?.cast<String>(),
      uri: json['uri'] as String?,
      history: HistoryDetail.fromJson(
        json['history'] as Map<String, dynamic>? ?? {},
      ),
      videos: json['videos'] as int?,
      authorName: json['author_name'] as String?,
      authorFace: json['author_face'] as String?,
      authorMid: json['author_mid'] as int?,
      viewAt: json['view_at'] as int? ?? 0,
      progress: json['progress'] as int?,
      badge: json['badge'] as String?,
      showTitle: json['show_title'] as String?,
      duration: json['duration'] as int?,
      current: json['current'] as String?,
      total: json['total'] as int?,
      newDesc: json['new_desc'] as String?,
      isFinish: json['is_finish'] as int?,
      isFav: json['is_fav'] as int?,
      kid: json['kid'] as int?,
      tagName: json['tag_name'] as String?,
      liveStatus: json['live_status'] as int?,
    );
  }

  final String title;
  final String? longTitle;
  final String cover;
  final List<String>? covers;
  final String? uri;
  final HistoryDetail history;
  final int? videos;
  final String? authorName;
  final String? authorFace;
  final int? authorMid;
  final int viewAt;
  final int? progress;
  final String? badge;
  final String? showTitle;
  final int? duration;
  final String? current;
  final int? total;
  final String? newDesc;
  final int? isFinish;
  final int? isFav;
  final int? kid;
  final String? tagName;
  final int? liveStatus;

  /// Get unique key for list
  String get uniqueKey => '${history.oid}-$viewAt';

  /// Check if this is an archive (video) type
  bool get isArchive => history.business == 'archive';

  /// Check if playable (has bvid)
  bool get isPlayable => history.bvid != null && history.bvid!.isNotEmpty;

  /// Format progress as string (e.g., "05:30 / 10:00")
  String get progressFormatted {
    if (progress == null || duration == null) return '';
    return '${_formatDuration(progress!)} / ${_formatDuration(duration!)}';
  }

  /// Format view time as relative string
  String get viewAtFormatted {
    final date = DateTime.fromMillisecondsSinceEpoch(viewAt * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${date.month}/${date.day}';
    }
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'long_title': longTitle,
        'cover': cover,
        'covers': covers,
        'uri': uri,
        'history': history.toJson(),
        'videos': videos,
        'author_name': authorName,
        'author_face': authorFace,
        'author_mid': authorMid,
        'view_at': viewAt,
        'progress': progress,
        'badge': badge,
        'show_title': showTitle,
        'duration': duration,
        'current': current,
        'total': total,
        'new_desc': newDesc,
        'is_finish': isFinish,
        'is_fav': isFav,
        'kid': kid,
        'tag_name': tagName,
        'live_status': liveStatus,
      };

  static String _normalizeCoverUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
