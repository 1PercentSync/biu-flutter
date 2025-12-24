/// Video owner/author information
class VideoOwner {
  const VideoOwner({
    required this.mid,
    required this.name,
    required this.face,
  });

  factory VideoOwner.fromJson(Map<String, dynamic> json) {
    return VideoOwner(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      face: json['face'] as String? ?? '',
    );
  }

  final int mid;
  final String name;
  final String face;

  Map<String, dynamic> toJson() => {
    'mid': mid,
    'name': name,
    'face': face,
  };
}

/// Video statistics
class VideoStat {
  const VideoStat({
    required this.aid,
    required this.view,
    required this.danmaku,
    required this.reply,
    required this.favorite,
    required this.coin,
    required this.share,
    required this.nowRank,
    required this.hisRank,
    required this.like,
    required this.dislike,
  });

  factory VideoStat.fromJson(Map<String, dynamic> json) {
    return VideoStat(
      aid: json['aid'] as int? ?? 0,
      view: json['view'] as int? ?? 0,
      danmaku: json['danmaku'] as int? ?? 0,
      reply: json['reply'] as int? ?? 0,
      favorite: json['favorite'] as int? ?? 0,
      coin: json['coin'] as int? ?? 0,
      share: json['share'] as int? ?? 0,
      nowRank: json['now_rank'] as int? ?? 0,
      hisRank: json['his_rank'] as int? ?? 0,
      like: json['like'] as int? ?? 0,
      dislike: json['dislike'] as int? ?? 0,
    );
  }

  final int aid;
  final int view;
  final int danmaku;
  final int reply;
  final int favorite;
  final int coin;
  final int share;
  final int nowRank;
  final int hisRank;
  final int like;
  final int dislike;

  Map<String, dynamic> toJson() => {
    'aid': aid,
    'view': view,
    'danmaku': danmaku,
    'reply': reply,
    'favorite': favorite,
    'coin': coin,
    'share': share,
    'now_rank': nowRank,
    'his_rank': hisRank,
    'like': like,
    'dislike': dislike,
  };
}

/// Video dimension
class VideoDimension {
  const VideoDimension({
    required this.width,
    required this.height,
    required this.rotate,
  });

  factory VideoDimension.fromJson(Map<String, dynamic> json) {
    return VideoDimension(
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

/// Video page (part)
class VideoPage {
  const VideoPage({
    required this.cid,
    required this.page,
    required this.from,
    required this.part,
    required this.duration,
    this.vid,
    this.weblink,
    this.dimension,
    this.firstFrame,
  });

  factory VideoPage.fromJson(Map<String, dynamic> json) {
    return VideoPage(
      cid: json['cid'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      from: json['from'] as String? ?? '',
      part: json['part'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      vid: json['vid'] as String?,
      weblink: json['weblink'] as String?,
      dimension: json['dimension'] != null
          ? VideoDimension.fromJson(json['dimension'] as Map<String, dynamic>)
          : null,
      firstFrame: json['first_frame'] as String?,
    );
  }

  final int cid;
  final int page;
  final String from;
  final String part;
  final int duration;
  final String? vid;
  final String? weblink;
  final VideoDimension? dimension;
  final String? firstFrame;

  Map<String, dynamic> toJson() => {
    'cid': cid,
    'page': page,
    'from': from,
    'part': part,
    'duration': duration,
    'vid': vid,
    'weblink': weblink,
    'dimension': dimension?.toJson(),
    'first_frame': firstFrame,
  };
}

/// Video info from web-interface/view API
class VideoInfo {
  const VideoInfo({
    required this.bvid,
    required this.aid,
    required this.videos,
    required this.tid,
    required this.tname,
    required this.copyright,
    required this.pic,
    required this.title,
    required this.pubdate,
    required this.ctime,
    required this.desc,
    required this.duration,
    required this.owner,
    required this.stat,
    required this.cid,
    this.dimension,
    this.pages = const [],
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      bvid: json['bvid'] as String? ?? '',
      aid: json['aid'] as int? ?? 0,
      videos: json['videos'] as int? ?? 0,
      tid: json['tid'] as int? ?? 0,
      tname: json['tname'] as String? ?? '',
      copyright: json['copyright'] as int? ?? 0,
      pic: json['pic'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pubdate: json['pubdate'] as int? ?? 0,
      ctime: json['ctime'] as int? ?? 0,
      desc: json['desc'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      owner: json['owner'] != null
          ? VideoOwner.fromJson(json['owner'] as Map<String, dynamic>)
          : const VideoOwner(mid: 0, name: '', face: ''),
      stat: json['stat'] != null
          ? VideoStat.fromJson(json['stat'] as Map<String, dynamic>)
          : const VideoStat(
              aid: 0,
              view: 0,
              danmaku: 0,
              reply: 0,
              favorite: 0,
              coin: 0,
              share: 0,
              nowRank: 0,
              hisRank: 0,
              like: 0,
              dislike: 0,
            ),
      cid: json['cid'] as int? ?? 0,
      dimension: json['dimension'] != null
          ? VideoDimension.fromJson(json['dimension'] as Map<String, dynamic>)
          : null,
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => VideoPage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String bvid;
  final int aid;
  final int videos;
  final int tid;
  final String tname;
  final int copyright;
  final String pic;
  final String title;
  final int pubdate;
  final int ctime;
  final String desc;
  final int duration;
  final VideoOwner owner;
  final VideoStat stat;
  final int cid;
  final VideoDimension? dimension;
  final List<VideoPage> pages;

  /// Get formatted duration string
  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'bvid': bvid,
    'aid': aid,
    'videos': videos,
    'tid': tid,
    'tname': tname,
    'copyright': copyright,
    'pic': pic,
    'title': title,
    'pubdate': pubdate,
    'ctime': ctime,
    'desc': desc,
    'duration': duration,
    'owner': owner.toJson(),
    'stat': stat.toJson(),
    'cid': cid,
    'dimension': dimension?.toJson(),
    'pages': pages.map((e) => e.toJson()).toList(),
  };
}
