/// Video item in watch later list
class WatchLaterItem {
  const WatchLaterItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.pic,
    required this.duration,
    required this.cid,
    required this.addAt,
    this.videos = 1,
    this.tid,
    this.tname,
    this.copyright = 1,
    this.pubdate,
    this.ctime,
    this.desc,
    this.state,
    this.progress = 0,
    this.owner,
    this.stat,
    this.dynamicContent,
    this.dimension,
  });

  factory WatchLaterItem.fromJson(Map<String, dynamic> json) {
    return WatchLaterItem(
      aid: json['aid'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pic: _normalizeCoverUrl(json['pic'] as String? ?? ''),
      duration: json['duration'] as int? ?? 0,
      cid: json['cid'] as int? ?? 0,
      addAt: json['add_at'] as int? ?? 0,
      videos: json['videos'] as int? ?? 1,
      tid: json['tid'] as int?,
      tname: json['tname'] as String?,
      copyright: json['copyright'] as int? ?? 1,
      pubdate: json['pubdate'] as int?,
      ctime: json['ctime'] as int?,
      desc: json['desc'] as String?,
      state: json['state'] as int?,
      progress: json['progress'] as int? ?? 0,
      owner: json['owner'] != null
          ? WatchLaterOwner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      stat: json['stat'] != null
          ? WatchLaterStat.fromJson(json['stat'] as Map<String, dynamic>)
          : null,
      dynamicContent: json['dynamic'] as String?,
      dimension: json['dimension'] != null
          ? WatchLaterDimension.fromJson(
              json['dimension'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final int aid;
  final String bvid;
  final String title;
  final String pic;
  final int duration;
  final int cid;
  final int addAt;
  final int videos;
  final int? tid;
  final String? tname;
  final int copyright;
  final int? pubdate;
  final int? ctime;
  final String? desc;
  final int? state;
  final int progress;
  final WatchLaterOwner? owner;
  final WatchLaterStat? stat;
  final String? dynamicContent;
  final WatchLaterDimension? dimension;

  /// Get unique key for list
  String get uniqueKey => bvid;

  /// Check if playable
  bool get isPlayable => bvid.isNotEmpty && cid > 0;

  /// Format duration as string (e.g., "05:30")
  String get durationFormatted => _formatDuration(duration);

  /// Format add time as relative string
  String get addAtFormatted {
    final date = DateTime.fromMillisecondsSinceEpoch(addAt * 1000);
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

  /// Format progress as string (e.g., "05:30 / 10:00")
  String get progressFormatted {
    if (progress <= 0 || duration <= 0) return '';
    return '${_formatDuration(progress)} / ${_formatDuration(duration)}';
  }

  /// Get progress ratio for progress bar
  double get progressRatio {
    if (duration <= 0) return 0;
    return (progress / duration).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'aid': aid,
        'bvid': bvid,
        'title': title,
        'pic': pic,
        'duration': duration,
        'cid': cid,
        'add_at': addAt,
        'videos': videos,
        'tid': tid,
        'tname': tname,
        'copyright': copyright,
        'pubdate': pubdate,
        'ctime': ctime,
        'desc': desc,
        'state': state,
        'progress': progress,
        'owner': owner?.toJson(),
        'stat': stat?.toJson(),
        'dynamic': dynamicContent,
        'dimension': dimension?.toJson(),
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

/// Owner info for watch later item
class WatchLaterOwner {
  const WatchLaterOwner({
    required this.mid,
    required this.name,
    this.face,
  });

  factory WatchLaterOwner.fromJson(Map<String, dynamic> json) {
    return WatchLaterOwner(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      face: json['face'] as String?,
    );
  }

  final int mid;
  final String name;
  final String? face;

  Map<String, dynamic> toJson() => {
        'mid': mid,
        'name': name,
        'face': face,
      };
}

/// Stat info for watch later item
class WatchLaterStat {
  const WatchLaterStat({
    this.view = 0,
    this.danmaku = 0,
    this.reply = 0,
    this.favorite = 0,
    this.coin = 0,
    this.share = 0,
    this.like = 0,
  });

  factory WatchLaterStat.fromJson(Map<String, dynamic> json) {
    return WatchLaterStat(
      view: json['view'] as int? ?? 0,
      danmaku: json['danmaku'] as int? ?? 0,
      reply: json['reply'] as int? ?? 0,
      favorite: json['favorite'] as int? ?? 0,
      coin: json['coin'] as int? ?? 0,
      share: json['share'] as int? ?? 0,
      like: json['like'] as int? ?? 0,
    );
  }

  final int view;
  final int danmaku;
  final int reply;
  final int favorite;
  final int coin;
  final int share;
  final int like;

  /// Format view count for display
  String get viewFormatted {
    if (view >= 100000000) {
      return '${(view / 100000000).toStringAsFixed(1)}亿';
    }
    if (view >= 10000) {
      return '${(view / 10000).toStringAsFixed(1)}万';
    }
    return view.toString();
  }

  Map<String, dynamic> toJson() => {
        'view': view,
        'danmaku': danmaku,
        'reply': reply,
        'favorite': favorite,
        'coin': coin,
        'share': share,
        'like': like,
      };
}

/// Dimension info for watch later item
class WatchLaterDimension {
  const WatchLaterDimension({
    this.width = 0,
    this.height = 0,
    this.rotate = 0,
  });

  factory WatchLaterDimension.fromJson(Map<String, dynamic> json) {
    return WatchLaterDimension(
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      rotate: json['rotate'] as int? ?? 0,
    );
  }

  final int width;
  final int height;
  final int rotate;

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'rotate': rotate,
      };
}
