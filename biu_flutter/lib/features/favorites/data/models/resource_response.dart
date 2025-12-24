import '../../domain/entities/fav_media.dart';
import 'folder_response.dart';

/// Response for folder resource list API.
class FolderResourceListResponse {
  const FolderResourceListResponse({
    required this.info,
    required this.medias,
    required this.hasMore,
  });

  factory FolderResourceListResponse.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final medias = json['medias'] as List<dynamic>? ?? [];
    return FolderResourceListResponse(
      info: FolderDetailModel.fromJson(info),
      medias: medias.map((e) => MediaModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  final FolderDetailModel info;
  final List<MediaModel> medias;
  final bool hasMore;
}

/// Media model from API response.
class MediaModel {
  const MediaModel({
    required this.id,
    required this.type,
    required this.title,
    required this.cover,
    required this.upper,
    required this.duration,
    this.intro = '',
    this.page = 1,
    this.attr = 0,
    this.ctime = 0,
    this.pubtime = 0,
    this.favTime = 0,
    this.bvid = '',
    this.cntInfo,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    final upper = json['upper'] as Map<String, dynamic>? ?? {};
    final cntInfo = json['cnt_info'] as Map<String, dynamic>?;
    return MediaModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as int? ?? 2,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      upper: MediaUpperModel.fromJson(upper),
      duration: json['duration'] as int? ?? 0,
      intro: json['intro'] as String? ?? '',
      page: json['page'] as int? ?? 1,
      attr: json['attr'] as int? ?? 0,
      ctime: json['ctime'] as int? ?? 0,
      pubtime: json['pubtime'] as int? ?? 0,
      favTime: json['fav_time'] as int? ?? 0,
      bvid: (json['bvid'] ?? json['bv_id']) as String? ?? '',
      cntInfo: cntInfo != null ? MediaCntInfoModel.fromJson(cntInfo) : null,
    );
  }

  final int id;
  final int type;
  final String title;
  final String cover;
  final MediaUpperModel upper;
  final int duration;
  final String intro;
  final int page;
  final int attr;
  final int ctime;
  final int pubtime;
  final int favTime;
  final String bvid;
  final MediaCntInfoModel? cntInfo;

  FavMedia toEntity() {
    return FavMedia(
      id: id,
      type: type,
      title: title,
      cover: cover,
      upper: upper.toEntity(),
      duration: duration,
      intro: intro,
      page: page,
      attr: attr,
      ctime: ctime,
      pubtime: pubtime,
      favTime: favTime,
      bvid: bvid,
      playCount: cntInfo?.play ?? 0,
      danmakuCount: cntInfo?.danmaku ?? 0,
      collectCount: cntInfo?.collect ?? 0,
    );
  }
}

/// Media upper (uploader) model.
class MediaUpperModel {
  const MediaUpperModel({
    required this.mid,
    required this.name,
    this.face = '',
  });

  factory MediaUpperModel.fromJson(Map<String, dynamic> json) {
    return MediaUpperModel(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      face: json['face'] as String? ?? '',
    );
  }

  final int mid;
  final String name;
  final String face;

  MediaUpper toEntity() {
    return MediaUpper(
      mid: mid,
      name: name,
      face: face,
    );
  }
}

/// Media count info model.
class MediaCntInfoModel {
  const MediaCntInfoModel({
    required this.collect,
    required this.play,
    required this.danmaku,
  });

  factory MediaCntInfoModel.fromJson(Map<String, dynamic> json) {
    return MediaCntInfoModel(
      collect: json['collect'] as int? ?? 0,
      play: json['play'] as int? ?? 0,
      danmaku: json['danmaku'] as int? ?? 0,
    );
  }

  final int collect;
  final int play;
  final int danmaku;
}
