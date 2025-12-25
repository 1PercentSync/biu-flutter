/// Musician model representing a music creator on Bilibili.
///
/// Maps to the response from `/x/centralization/interface/musician/list`
class Musician {
  const Musician({
    required this.id,
    required this.aid,
    required this.bvid,
    required this.archiveCount,
    required this.fansCount,
    required this.cover,
    required this.desc,
    required this.duration,
    required this.pubTime,
    required this.danmuCount,
    required this.selfIntro,
    required this.title,
    required this.uid,
    required this.vtDisplay,
    required this.vvCount,
    required this.isVt,
    required this.username,
    required this.userProfile,
    required this.userLevel,
    required this.lightning,
  });

  factory Musician.fromJson(Map<String, dynamic> json) {
    // Note: uid comes as string from API (per source project musician-list.ts)
    final uidValue = json['uid'];
    final uid = uidValue is int
        ? uidValue
        : int.tryParse(uidValue?.toString() ?? '') ?? 0;

    return Musician(
      id: json['id'] as int? ?? 0,
      aid: json['aid']?.toString() ?? '',
      bvid: json['bvid']?.toString() ?? '',
      archiveCount: json['archive_count'] as int? ?? 0,
      fansCount: json['fans_count'] as int? ?? 0,
      cover: json['cover'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      pubTime: json['pub_time'] as int? ?? 0,
      danmuCount: json['danmu_count'] as int? ?? 0,
      selfIntro: json['self_intro'] as String? ?? '',
      title: json['title'] as String? ?? '',
      uid: uid,
      vtDisplay: json['vt_display'] as String? ?? '',
      vvCount: json['vv_count'] as int? ?? 0,
      isVt: json['is_vt'] as int? ?? 0,
      lightning: json['lightning'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      userProfile: json['user_profile'] as String? ?? '',
      userLevel: json['user_level'] as int? ?? 0,
    );
  }

  /// Unique identifier
  final int id;

  /// Video aid
  final String aid;

  /// Video bvid
  final String bvid;

  /// Number of archived videos
  final int archiveCount;

  /// Number of fans
  final int fansCount;

  /// Cover image URL
  final String cover;

  /// Description
  final String desc;

  /// Video duration in seconds
  final int duration;

  /// Publish timestamp
  final int pubTime;

  /// Danmaku count
  final int danmuCount;

  /// Self introduction
  final String selfIntro;

  /// Video title
  final String title;

  /// User ID
  final int uid;

  /// VT display text
  final String vtDisplay;

  /// View count
  final int vvCount;

  /// Is VT flag
  final int isVt;

  /// Lightning flag
  final int lightning;

  /// Username
  final String username;

  /// User profile avatar URL
  final String userProfile;

  /// User level
  final int userLevel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aid': aid,
      'bvid': bvid,
      'archive_count': archiveCount,
      'fans_count': fansCount,
      'cover': cover,
      'desc': desc,
      'duration': duration,
      'pub_time': pubTime,
      'danmu_count': danmuCount,
      'self_intro': selfIntro,
      'title': title,
      'uid': uid,
      'vt_display': vtDisplay,
      'vv_count': vvCount,
      'is_vt': isVt,
      'lightning': lightning,
      'username': username,
      'user_profile': userProfile,
      'user_level': userLevel,
    };
  }
}

/// Level source for musician list API
enum MusicianLevelSource {
  /// All musicians
  all(1),

  /// Newly registered musicians
  newMusicians(2);

  const MusicianLevelSource(this.value);
  final int value;
}
