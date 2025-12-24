import '../../domain/entities/favorites_folder.dart';

/// Response for created folder list API.
class CreatedFolderListResponse {
  const CreatedFolderListResponse({
    required this.count,
    required this.list,
    required this.hasMore,
  });

  factory CreatedFolderListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    return CreatedFolderListResponse(
      count: json['count'] as int? ?? 0,
      list: list.map((e) => FolderModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  final int count;
  final List<FolderModel> list;
  final bool hasMore;
}

/// Response for collected folder list API.
class CollectedFolderListResponse {
  const CollectedFolderListResponse({
    required this.count,
    required this.list,
    required this.hasMore,
  });

  factory CollectedFolderListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    return CollectedFolderListResponse(
      count: json['count'] as int? ?? 0,
      list: list.map((e) => FolderModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  final int count;
  final List<FolderModel> list;
  final bool hasMore;
}

/// Response for all created folders API (includes fav_state).
class AllCreatedFolderListResponse {
  const AllCreatedFolderListResponse({
    required this.count,
    required this.list,
  });

  factory AllCreatedFolderListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    return AllCreatedFolderListResponse(
      count: json['count'] as int? ?? 0,
      list: list.map((e) => FolderWithFavStateModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final int count;
  final List<FolderWithFavStateModel> list;
}

/// Folder model with favorite state (for resource selection).
class FolderWithFavStateModel {
  const FolderWithFavStateModel({
    required this.id,
    required this.fid,
    required this.mid,
    required this.attr,
    required this.title,
    required this.mediaCount,
    required this.favState,
  });

  factory FolderWithFavStateModel.fromJson(Map<String, dynamic> json) {
    return FolderWithFavStateModel(
      id: json['id'] as int? ?? 0,
      fid: json['fid'] as int? ?? 0,
      mid: json['mid'] as int? ?? 0,
      attr: json['attr'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      mediaCount: json['media_count'] as int? ?? 0,
      favState: json['fav_state'] as int? ?? 0,
    );
  }

  final int id;
  final int fid;
  final int mid;
  final int attr;
  final String title;
  final int mediaCount;
  final int favState;

  bool get isFavorited => favState == 1;
}

/// Folder model from API response.
class FolderModel {
  const FolderModel({
    required this.id,
    required this.fid,
    required this.mid,
    required this.attr,
    required this.title,
    required this.cover,
    required this.upper,
    required this.mediaCount,
    required this.ctime,
    required this.mtime,
    this.intro = '',
    this.state = 0,
    this.favState = 0,
    this.type = 11,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    final upper = json['upper'] as Map<String, dynamic>? ?? {};
    return FolderModel(
      id: json['id'] as int? ?? 0,
      fid: json['fid'] as int? ?? 0,
      mid: json['mid'] as int? ?? 0,
      attr: json['attr'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      upper: UpperModel.fromJson(upper),
      mediaCount: json['media_count'] as int? ?? 0,
      ctime: json['ctime'] as int? ?? 0,
      mtime: json['mtime'] as int? ?? 0,
      intro: json['intro'] as String? ?? '',
      state: json['state'] as int? ?? 0,
      favState: json['fav_state'] as int? ?? 0,
      type: json['type'] as int? ?? 11,
    );
  }

  final int id;
  final int fid;
  final int mid;
  final int attr;
  final String title;
  final String cover;
  final UpperModel upper;
  final int mediaCount;
  final int ctime;
  final int mtime;
  final String intro;
  final int state;
  final int favState;
  final int type;

  FavoritesFolder toEntity() {
    return FavoritesFolder(
      id: id,
      fid: fid,
      mid: mid,
      attr: attr,
      title: title,
      cover: cover,
      upper: upper.toEntity(),
      mediaCount: mediaCount,
      ctime: ctime,
      mtime: mtime,
      intro: intro,
      state: state,
      favState: favState,
      type: type,
    );
  }
}

/// Upper (creator) model from API response.
class UpperModel {
  const UpperModel({
    required this.mid,
    required this.name,
    this.face = '',
  });

  factory UpperModel.fromJson(Map<String, dynamic> json) {
    return UpperModel(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      face: json['face'] as String? ?? '',
    );
  }

  final int mid;
  final String name;
  final String face;

  FolderUpper toEntity() {
    return FolderUpper(
      mid: mid,
      name: name,
      face: face,
    );
  }
}

/// Response for folder info API.
class FolderInfoResponse {
  const FolderInfoResponse({
    required this.folder,
  });

  factory FolderInfoResponse.fromJson(Map<String, dynamic> json) {
    return FolderInfoResponse(
      folder: FolderDetailModel.fromJson(json),
    );
  }

  final FolderDetailModel folder;
}

/// Detailed folder model with count info.
class FolderDetailModel extends FolderModel {
  const FolderDetailModel({
    required super.id,
    required super.fid,
    required super.mid,
    required super.attr,
    required super.title,
    required super.cover,
    required super.upper,
    required super.mediaCount,
    required super.ctime,
    required super.mtime,
    super.intro,
    super.state,
    super.favState,
    super.type,
    this.likeState = 0,
    this.cntInfo,
  });

  factory FolderDetailModel.fromJson(Map<String, dynamic> json) {
    final upper = json['upper'] as Map<String, dynamic>? ?? {};
    final cntInfo = json['cnt_info'] as Map<String, dynamic>?;
    return FolderDetailModel(
      id: json['id'] as int? ?? 0,
      fid: json['fid'] as int? ?? 0,
      mid: json['mid'] as int? ?? 0,
      attr: json['attr'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      upper: UpperModel.fromJson(upper),
      mediaCount: json['media_count'] as int? ?? 0,
      ctime: json['ctime'] as int? ?? 0,
      mtime: json['mtime'] as int? ?? 0,
      intro: json['intro'] as String? ?? '',
      state: json['state'] as int? ?? 0,
      favState: json['fav_state'] as int? ?? 0,
      type: json['type'] as int? ?? 11,
      likeState: json['like_state'] as int? ?? 0,
      cntInfo: cntInfo != null ? FolderCntInfoModel.fromJson(cntInfo) : null,
    );
  }

  final int likeState;
  final FolderCntInfoModel? cntInfo;
}

/// Folder count info model.
class FolderCntInfoModel {
  const FolderCntInfoModel({
    required this.collect,
    required this.play,
    required this.thumbUp,
    required this.share,
  });

  factory FolderCntInfoModel.fromJson(Map<String, dynamic> json) {
    return FolderCntInfoModel(
      collect: json['collect'] as int? ?? 0,
      play: json['play'] as int? ?? 0,
      thumbUp: json['thumb_up'] as int? ?? 0,
      share: json['share'] as int? ?? 0,
    );
  }

  final int collect;
  final int play;
  final int thumbUp;
  final int share;
}
