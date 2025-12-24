// User space video search response model
// Reference: biu/src/service/space-wbi-arc-search.ts

/// Video item in user space
class SpaceArcVListItem {
  const SpaceArcVListItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.pic,
    required this.play,
    required this.comment,
    required this.author,
    required this.mid,
    required this.created,
    required this.length,
    this.description,
  });

  factory SpaceArcVListItem.fromJson(Map<String, dynamic> json) {
    return SpaceArcVListItem(
      aid: json['aid'] as int? ?? 0,
      bvid: json['bvid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
      play: json['play'] as int? ?? 0,
      comment: json['comment'] as int? ?? 0,
      author: json['author'] as String? ?? '',
      mid: json['mid'] as int? ?? 0,
      created: json['created'] as int? ?? 0,
      length: json['length'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  /// Video avid
  final int aid;

  /// Video bvid
  final String bvid;

  /// Video title
  final String title;

  /// Video cover URL
  final String pic;

  /// Play count
  final int play;

  /// Comment count
  final int comment;

  /// Author nickname
  final String author;

  /// Author mid
  final int mid;

  /// Created time (Unix seconds)
  final int created;

  /// Video duration string (e.g., "3:20")
  final String length;

  /// Video description
  final String? description;

  /// Convert duration string to seconds
  int get durationSeconds {
    final parts = length.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    } else if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return hours * 3600 + minutes * 60 + seconds;
    }
    return 0;
  }

  /// Get created DateTime
  DateTime get createdDate =>
      DateTime.fromMillisecondsSinceEpoch(created * 1000);
}

/// Category statistics in user space
class SpaceArcTListItem {
  const SpaceArcTListItem({
    required this.tid,
    required this.count,
    this.name,
  });

  factory SpaceArcTListItem.fromJson(Map<String, dynamic> json) {
    return SpaceArcTListItem(
      tid: json['tid'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      name: json['name'] as String?,
    );
  }

  /// Category tid
  final int tid;

  /// Video count in this category
  final int count;

  /// Category name
  final String? name;
}

/// Video list data
class SpaceArcSearchList {
  const SpaceArcSearchList({
    required this.vlist, this.tlist,
  });

  factory SpaceArcSearchList.fromJson(Map<String, dynamic> json) {
    final tlistData = json['tlist'] as Map<String, dynamic>?;
    final vlistData = json['vlist'] as List<dynamic>?;

    Map<int, SpaceArcTListItem>? tlist;
    if (tlistData != null) {
      tlist = {};
      tlistData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final tid = int.tryParse(key) ?? 0;
          tlist![tid] = SpaceArcTListItem.fromJson(value);
        }
      });
    }

    return SpaceArcSearchList(
      tlist: tlist,
      vlist: vlistData
              ?.map((e) => SpaceArcVListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Category statistics (key is tid)
  final Map<int, SpaceArcTListItem>? tlist;

  /// Video list
  final List<SpaceArcVListItem> vlist;
}

/// Pagination info
class SpaceArcSearchPage {
  const SpaceArcSearchPage({
    required this.pn,
    required this.ps,
    required this.count,
  });

  factory SpaceArcSearchPage.fromJson(Map<String, dynamic> json) {
    return SpaceArcSearchPage(
      pn: json['pn'] as int? ?? 1,
      ps: json['ps'] as int? ?? 30,
      count: json['count'] as int? ?? 0,
    );
  }

  /// Current page number (starting from 1)
  final int pn;

  /// Page size
  final int ps;

  /// Total count
  final int count;

  /// Total pages
  int get totalPages => (count / ps).ceil();

  /// Has more pages
  bool get hasMore => pn < totalPages;
}

/// Space arc search response data
class SpaceArcSearchData {
  const SpaceArcSearchData({
    required this.list,
    required this.page,
  });

  factory SpaceArcSearchData.fromJson(Map<String, dynamic> json) {
    return SpaceArcSearchData(
      list: SpaceArcSearchList.fromJson(
          json['list'] as Map<String, dynamic>? ?? {}),
      page: SpaceArcSearchPage.fromJson(
          json['page'] as Map<String, dynamic>? ?? {}),
    );
  }

  final SpaceArcSearchList list;
  final SpaceArcSearchPage page;
}
