/// Search video item from search results
class SearchVideoItem {
  const SearchVideoItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.author,
    required this.mid,
    required this.pic,
    this.pubdate,
    this.play,
    this.danmaku,
    this.favorites,
    this.review,
    this.duration,
    this.description,
    this.tag,
  });

  factory SearchVideoItem.fromJson(Map<String, dynamic> json) {
    return SearchVideoItem(
      aid: json['aid'] as int? ?? json['id'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: _stripHtmlTags(json['title'] as String? ?? ''),
      author: json['author'] as String? ?? '',
      mid: json['mid'] as int? ?? 0,
      pic: _normalizePicUrl(json['pic'] as String? ?? ''),
      pubdate: json['pubdate'] as int?,
      play: json['play'] as int?,
      danmaku: json['video_review'] as int? ?? json['danmaku'] as int?,
      favorites: json['favorites'] as int?,
      review: json['review'] as int?,
      duration: _parseDuration(json['duration']),
      description: json['description'] as String?,
      tag: json['tag'] as String?,
    );
  }

  final int aid;
  final String bvid;
  final String title;
  final String author;
  final int mid;
  final String pic;
  final int? pubdate;
  final int? play;
  final int? danmaku;
  final int? favorites;
  final int? review;
  final int? duration;
  final String? description;
  final String? tag;

  /// Get formatted duration string
  String get durationFormatted {
    if (duration == null) return '--:--';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted play count
  String get playFormatted {
    if (play == null) return '--';
    if (play! >= 10000) {
      return '${(play! / 10000).toStringAsFixed(1)}万';
    }
    return play.toString();
  }

  Map<String, dynamic> toJson() => {
    'aid': aid,
    'bvid': bvid,
    'title': title,
    'author': author,
    'mid': mid,
    'pic': pic,
    'pubdate': pubdate,
    'play': play,
    'danmaku': danmaku,
    'favorites': favorites,
    'review': review,
    'duration': duration,
    'description': description,
    'tag': tag,
  };

  /// Strip HTML tags from title (Bilibili returns highlighted titles with <em>)
  static String _stripHtmlTags(String text) {
    return text.replaceAll(RegExp('<[^>]*>'), '');
  }

  /// Normalize picture URL (add https if missing)
  static String _normalizePicUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }

  /// Parse duration from string or int
  static int? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    if (duration is int) return duration;
    if (duration is String) {
      // Format: "HH:MM:SS" or "MM:SS"
      final parts = duration.split(':');
      if (parts.isEmpty) return null;
      try {
        if (parts.length == 3) {
          return int.parse(parts[0]) * 3600 +
              int.parse(parts[1]) * 60 +
              int.parse(parts[2]);
        } else if (parts.length == 2) {
          return int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
        return int.tryParse(duration);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

/// Search user item from search results
class SearchUserItem {
  const SearchUserItem({
    required this.mid,
    required this.uname,
    required this.usign,
    required this.upic,
    this.fans,
    this.level,
    this.officialType,
    this.officialDesc,
  });

  factory SearchUserItem.fromJson(Map<String, dynamic> json) {
    final official = json['official_verify'] as Map<String, dynamic>?;
    return SearchUserItem(
      mid: json['mid'] as int? ?? 0,
      uname: json['uname'] as String? ?? '',
      usign: json['usign'] as String? ?? '',
      upic: _normalizePicUrl(json['upic'] as String? ?? ''),
      fans: json['fans'] as int?,
      level: json['level'] as int?,
      officialType: official?['type'] as int?,
      officialDesc: official?['desc'] as String?,
    );
  }

  final int mid;
  final String uname;
  final String usign;
  final String upic;
  final int? fans;
  final int? level;
  final int? officialType;
  final String? officialDesc;

  /// Get formatted fans count
  String get fansFormatted {
    if (fans == null) return '--';
    if (fans! >= 10000) {
      return '${(fans! / 10000).toStringAsFixed(1)}万';
    }
    return fans.toString();
  }

  /// Check if user is officially verified
  bool get isOfficial => officialType != null && officialType! >= 0;

  Map<String, dynamic> toJson() => {
    'mid': mid,
    'uname': uname,
    'usign': usign,
    'upic': upic,
    'fans': fans,
    'level': level,
    'official_verify': {
      'type': officialType,
      'desc': officialDesc,
    },
  };

  static String _normalizePicUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }
}

/// Search result module types
enum SearchModuleType {
  video('video'),
  user('bili_user'),
  article('article'),
  photo('photo'),
  live('live'),
  mediaBangumi('media_bangumi'),
  mediaFt('media_ft');

  const SearchModuleType(this.value);
  final String value;

  static SearchModuleType? fromString(String value) {
    for (final type in SearchModuleType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// Comprehensive search result
class SearchAllResult {
  const SearchAllResult({
    required this.seid,
    required this.page,
    required this.pageSize,
    required this.numResults,
    required this.numPages,
    this.topTlist = const {},
    this.result = const [],
  });

  factory SearchAllResult.fromJson(Map<String, dynamic> json) {
    return SearchAllResult(
      seid: json['seid'] as String? ?? '',
      page: json['page'] as int? ?? 1,
      pageSize: json['pagesize'] as int? ?? json['page_size'] as int? ?? 20,
      numResults: json['numResults'] as int? ?? 0,
      numPages: json['numPages'] as int? ?? 0,
      topTlist: (json['top_tlist'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int? ?? 0),
          ) ??
          {},
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => SearchResultModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String seid;
  final int page;
  final int pageSize;
  final int numResults;
  final int numPages;
  final Map<String, int> topTlist;
  final List<SearchResultModule> result;

  /// Get video results
  List<SearchVideoItem> get videoResults {
    final module = result.where((m) => m.resultType == 'video').firstOrNull;
    if (module == null) return [];
    return module.data
        .map((e) => SearchVideoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'seid': seid,
    'page': page,
    'pagesize': pageSize,
    'numResults': numResults,
    'numPages': numPages,
    'top_tlist': topTlist,
    'result': result.map((e) => e.toJson()).toList(),
  };
}

/// Search result module
class SearchResultModule {
  const SearchResultModule({
    required this.resultType,
    required this.data,
  });

  factory SearchResultModule.fromJson(Map<String, dynamic> json) {
    return SearchResultModule(
      resultType: json['result_type'] as String? ?? '',
      data: json['data'] as List<dynamic>? ?? [],
    );
  }

  final String resultType;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
    'result_type': resultType,
    'data': data,
  };
}

/// Type search result
class SearchTypeResult<T> {
  const SearchTypeResult({
    required this.seid,
    required this.page,
    required this.pageSize,
    required this.numResults,
    required this.numPages,
    required this.result,
  });

  final String seid;
  final int page;
  final int pageSize;
  final int numResults;
  final int numPages;
  final List<T> result;

  Map<String, dynamic> toJson() => {
    'seid': seid,
    'page': page,
    'pagesize': pageSize,
    'numResults': numResults,
    'numPages': numPages,
  };
}
