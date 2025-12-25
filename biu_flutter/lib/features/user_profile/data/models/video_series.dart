/// Video series (season) item.
///
/// Represents a single video series/season in a user's profile.
/// Source: biu/src/pages/user-profile/video-series.tsx
/// Source: biu/src/service/space-seasons-series-list.ts
class VideoSeriesItem {
  const VideoSeriesItem({
    required this.id,
    required this.name,
    required this.cover,
    required this.total,
    required this.ctime,
    this.intro,
    this.mid,
    this.isSeason = true,
  });

  /// Parses a season item from JSON.
  factory VideoSeriesItem.fromSeasonJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return VideoSeriesItem(
      id: meta['season_id'] as int? ?? 0,
      name: meta['name'] as String? ?? '',
      cover: meta['cover'] as String? ?? '',
      total: meta['total'] as int? ?? 0,
      intro: meta['description'] as String? ?? '',
      mid: meta['mid'] as int?,
      ctime: meta['ptime'] as int? ?? 0,
    );
  }

  /// Parses a series item from JSON.
  factory VideoSeriesItem.fromSeriesJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return VideoSeriesItem(
      id: meta['series_id'] as int? ?? 0,
      name: meta['name'] as String? ?? '',
      cover: meta['cover'] as String? ?? '',
      total: meta['total'] as int? ?? 0,
      intro: meta['description'] as String? ?? '',
      mid: meta['mid'] as int?,
      ctime: meta['ctime'] as int? ?? 0,
      isSeason: false,
    );
  }

  /// The season/series ID
  final int id;

  /// The name/title of the series
  final String name;

  /// Cover image URL
  final String cover;

  /// Total number of videos in the series
  final int total;

  /// Introduction/description
  final String? intro;

  /// User mid (owner)
  final int? mid;

  /// Creation/publish time (unix timestamp)
  final int ctime;

  /// Whether this is a season (合集) or series (视频列表)
  final bool isSeason;
}

/// Seasons and series list response.
///
/// API: GET /x/polymer/web-space/seasons_series_list
/// Source: biu/src/service/space-seasons-series-list.ts
class SeasonsSeriesListResponse {
  const SeasonsSeriesListResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory SeasonsSeriesListResponse.fromJson(Map<String, dynamic> json) {
    return SeasonsSeriesListResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SeasonsSeriesData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Response code (0 = success)
  final int code;

  /// Response message
  final String message;

  /// Response data
  final SeasonsSeriesData? data;

  /// Check if request was successful
  bool get isSuccess => code == 0;
}

/// Data container for seasons and series list.
class SeasonsSeriesData {
  const SeasonsSeriesData({this.itemsList});

  factory SeasonsSeriesData.fromJson(Map<String, dynamic> json) {
    return SeasonsSeriesData(
      itemsList: json['items_lists'] != null
          ? ItemsList.fromJson(json['items_lists'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The items list containing seasons and series
  final ItemsList? itemsList;
}

/// Container for seasons and series lists with pagination.
class ItemsList {
  const ItemsList({
    required this.seasonsList,
    required this.seriesList,
    this.page,
  });

  factory ItemsList.fromJson(Map<String, dynamic> json) {
    return ItemsList(
      seasonsList: (json['seasons_list'] as List<dynamic>?)
              ?.map((e) =>
                  VideoSeriesItem.fromSeasonJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      seriesList: (json['series_list'] as List<dynamic>?)
              ?.map((e) =>
                  VideoSeriesItem.fromSeriesJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] != null
          ? SeriesPage.fromJson(json['page'] as Map<String, dynamic>)
          : null,
    );
  }

  /// List of seasons (合集)
  final List<VideoSeriesItem> seasonsList;

  /// List of series (视频列表)
  final List<VideoSeriesItem> seriesList;

  /// Pagination information
  final SeriesPage? page;

  /// Get all items (seasons + series) combined
  List<VideoSeriesItem> get allItems => [...seasonsList, ...seriesList];
}

/// Pagination info for series list.
class SeriesPage {
  const SeriesPage({
    required this.pageNum,
    required this.pageSize,
    required this.total,
  });

  factory SeriesPage.fromJson(Map<String, dynamic> json) {
    return SeriesPage(
      pageNum: json['page_num'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }

  /// Current page number (1-based)
  final int pageNum;

  /// Page size
  final int pageSize;

  /// Total number of items
  final int total;

  /// Calculate total number of pages
  int get totalPages => (total / pageSize).ceil();
}
