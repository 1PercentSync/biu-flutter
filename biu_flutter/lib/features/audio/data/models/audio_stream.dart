/// Audio stream quality info
class AudioStreamQuality {
  const AudioStreamQuality({
    required this.type,
    required this.desc,
    required this.size,
    required this.bps,
    required this.tag,
    required this.require,
    required this.title,
  });

  factory AudioStreamQuality.fromJson(Map<String, dynamic> json) {
    return AudioStreamQuality(
      type: json['type'] as int? ?? 0,
      desc: json['desc'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      bps: json['bps'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      require: json['require'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  /// Quality type (0: 128k, 1: 192k, 2: 320k, 3: flac)
  final int type;
  final String desc;
  final int size;
  final String bps;
  final String tag;
  /// Whether VIP is required (0: no, 1: yes)
  final int require;
  final String title;

  bool get requiresVip => require == 1;

  Map<String, dynamic> toJson() => {
    'type': type,
    'desc': desc,
    'size': size,
    'bps': bps,
    'tag': tag,
    'require': require,
    'title': title,
  };
}

/// Audio stream URL data
class AudioStreamData {
  const AudioStreamData({
    required this.sid,
    required this.type,
    required this.info,
    required this.timeout,
    required this.size,
    required this.cdns,
    this.qualities = const [],
    this.title,
    this.cover,
  });

  factory AudioStreamData.fromJson(Map<String, dynamic> json) {
    return AudioStreamData(
      sid: json['sid'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      info: json['info'] as String? ?? '',
      timeout: json['timeout'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      cdns: (json['cdns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      qualities: (json['qualities'] as List<dynamic>?)
              ?.map((e) => AudioStreamQuality.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      title: json['title'] as String?,
      cover: json['cover'] as String?,
    );
  }

  final int sid;
  final int type;
  final String info;
  final int timeout;
  final int size;
  final List<String> cdns;
  final List<AudioStreamQuality> qualities;
  final String? title;
  final String? cover;

  /// Get the primary stream URL
  String? get primaryUrl => cdns.isNotEmpty ? cdns.first : null;

  /// Get backup URLs
  List<String> get backupUrls => cdns.skip(1).toList();

  Map<String, dynamic> toJson() => {
    'sid': sid,
    'type': type,
    'info': info,
    'timeout': timeout,
    'size': size,
    'cdns': cdns,
    'qualities': qualities.map((e) => e.toJson()).toList(),
    'title': title,
    'cover': cover,
  };
}

/// Audio stream response
class AudioStreamResponse {
  const AudioStreamResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory AudioStreamResponse.fromJson(Map<String, dynamic> json) {
    return AudioStreamResponse(
      code: json['code'] as int? ?? -1,
      msg: json['msg'] as String? ?? json['message'] as String? ?? '',
      data: json['data'] != null
          ? AudioStreamData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final int code;
  final String msg;
  final AudioStreamData? data;

  bool get isSuccess => code == 0;

  Map<String, dynamic> toJson() => {
    'code': code,
    'msg': msg,
    'data': data?.toJson(),
  };
}

/// Statistics for an audio song
class AudioSongStatistic {
  const AudioSongStatistic({
    required this.sid,
    required this.play,
    required this.collect,
    required this.comment,
    required this.share,
  });

  factory AudioSongStatistic.fromJson(Map<String, dynamic> json) {
    return AudioSongStatistic(
      sid: json['sid'] as int? ?? 0,
      play: json['play'] as int? ?? 0,
      collect: json['collect'] as int? ?? 0,
      comment: json['comment'] as int? ?? 0,
      share: json['share'] as int? ?? 0,
    );
  }

  /// Audio song ID
  final int sid;

  /// Play count
  final int play;

  /// Collect (favorite) count
  final int collect;

  /// Comment count
  final int comment;

  /// Share count
  final int share;

  Map<String, dynamic> toJson() => {
    'sid': sid,
    'play': play,
    'collect': collect,
    'comment': comment,
    'share': share,
  };
}

/// Audio song info data
/// Source: biu/src/service/audio-song-info.ts#AudioSongInfoData
class AudioSongInfo {
  const AudioSongInfo({
    required this.id,
    required this.uid,
    required this.uname,
    required this.author,
    required this.title,
    required this.cover,
    required this.intro,
    required this.lyric,
    required this.duration,
    required this.passtime,
    required this.curtime,
    required this.aid,
    required this.bvid,
    required this.cid,
    this.statistic,
    this.coinNum = 0,
  });

  factory AudioSongInfo.fromJson(Map<String, dynamic> json) {
    return AudioSongInfo(
      id: json['id'] as int? ?? 0,
      uid: json['uid'] as int? ?? 0,
      uname: json['uname'] as String? ?? '',
      author: json['author'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      lyric: json['lyric'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      passtime: json['passtime'] as int? ?? 0,
      curtime: json['curtime'] as int? ?? 0,
      aid: json['aid'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      cid: json['cid'] as int? ?? 0,
      statistic: json['statistic'] != null
          ? AudioSongStatistic.fromJson(json['statistic'] as Map<String, dynamic>)
          : null,
      coinNum: json['coin_num'] as int? ?? 0,
    );
  }

  /// Audio song ID
  final int id;

  /// Uploader user ID
  final int uid;

  /// Uploader username
  final String uname;

  /// Author name
  final String author;

  /// Song title
  final String title;

  /// Cover image URL
  final String cover;

  /// Song introduction
  final String intro;

  /// Lyrics URL (LRC format)
  final String lyric;

  /// Duration in seconds
  final int duration;

  /// Publish timestamp
  final int passtime;

  /// Current request timestamp
  final int curtime;

  /// Associated video AVID (0 if none)
  final int aid;

  /// Associated video BVID (empty if none)
  final String bvid;

  /// Associated video CID (0 if none)
  final int cid;

  /// Song statistics
  final AudioSongStatistic? statistic;

  /// Coin count
  final int coinNum;

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'uname': uname,
    'author': author,
    'title': title,
    'cover': cover,
    'intro': intro,
    'lyric': lyric,
    'duration': duration,
    'passtime': passtime,
    'curtime': curtime,
    'aid': aid,
    'bvid': bvid,
    'cid': cid,
    'statistic': statistic?.toJson(),
    'coin_num': coinNum,
  };
}
