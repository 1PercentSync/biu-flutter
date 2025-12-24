/// Represents a favorites folder on Bilibili.
class FavoritesFolder {
  const FavoritesFolder({
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

  /// Full folder id (mlid) = original id + creator mid suffix (2 digits)
  final int id;

  /// Original folder id
  final int fid;

  /// Creator mid
  final int mid;

  /// Attribute flags (0: public, 1: private)
  final int attr;

  /// Folder title
  final String title;

  /// Cover image URL
  final String cover;

  /// Creator info
  final FolderUpper upper;

  /// Number of items in folder
  final int mediaCount;

  /// Creation timestamp
  final int ctime;

  /// Last modified timestamp
  final int mtime;

  /// Folder description
  final String intro;

  /// Folder state (0: normal, 1: invalid)
  final int state;

  /// Favorite state (0: not collected, 1: collected)
  final int favState;

  /// Folder type (11: video folder, 21: video collection)
  final int type;

  /// Whether this folder is private
  bool get isPrivate => (attr & 1) == 1;

  /// Whether this is the default folder
  bool get isDefault => ((attr >> 1) & 1) == 0;

  FavoritesFolder copyWith({
    int? id,
    int? fid,
    int? mid,
    int? attr,
    String? title,
    String? cover,
    FolderUpper? upper,
    int? mediaCount,
    int? ctime,
    int? mtime,
    String? intro,
    int? state,
    int? favState,
    int? type,
  }) {
    return FavoritesFolder(
      id: id ?? this.id,
      fid: fid ?? this.fid,
      mid: mid ?? this.mid,
      attr: attr ?? this.attr,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      upper: upper ?? this.upper,
      mediaCount: mediaCount ?? this.mediaCount,
      ctime: ctime ?? this.ctime,
      mtime: mtime ?? this.mtime,
      intro: intro ?? this.intro,
      state: state ?? this.state,
      favState: favState ?? this.favState,
      type: type ?? this.type,
    );
  }
}

/// Folder creator info
class FolderUpper {
  const FolderUpper({
    required this.mid,
    required this.name,
    this.face = '',
  });

  /// Creator mid
  final int mid;

  /// Creator name
  final String name;

  /// Creator avatar URL
  final String face;

  FolderUpper copyWith({
    int? mid,
    String? name,
    String? face,
  }) {
    return FolderUpper(
      mid: mid ?? this.mid,
      name: name ?? this.name,
      face: face ?? this.face,
    );
  }
}
