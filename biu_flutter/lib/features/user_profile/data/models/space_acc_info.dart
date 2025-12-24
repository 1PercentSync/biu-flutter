// User space detailed information model
// Reference: biu/src/service/space-wbi-acc-info.ts

/// User space detailed information
class SpaceAccInfo {
  const SpaceAccInfo({
    required this.mid,
    required this.name,
    required this.sex,
    required this.face,
    required this.sign,
    required this.level,
    this.faceNft = 0,
    this.rank = 0,
    this.silence = 0,
    this.coins = 0,
    this.fansBadge = false,
    this.fansMedal,
    this.official,
    this.vip,
    this.pendant,
    this.nameplate,
    this.isFollowed = false,
    this.topPhoto,
    this.topPhotoV2,
    this.liveRoom,
    this.birthday,
    this.school,
    this.profession,
    this.tags,
    this.isSeniorMember = 0,
  });

  factory SpaceAccInfo.fromJson(Map<String, dynamic> json) {
    return SpaceAccInfo(
      mid: json['mid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sex: json['sex'] as String? ?? 'unknown',
      face: json['face'] as String? ?? '',
      sign: json['sign'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      faceNft: json['face_nft'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      silence: json['silence'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      fansBadge: json['fans_badge'] as bool? ?? false,
      fansMedal: json['fans_medal'] != null
          ? FansMedal.fromJson(json['fans_medal'] as Map<String, dynamic>)
          : null,
      official: json['official'] != null
          ? OfficialInfo.fromJson(json['official'] as Map<String, dynamic>)
          : null,
      vip: json['vip'] != null
          ? VipInfo.fromJson(json['vip'] as Map<String, dynamic>)
          : null,
      pendant: json['pendant'] != null
          ? Pendant.fromJson(json['pendant'] as Map<String, dynamic>)
          : null,
      nameplate: json['nameplate'] != null
          ? Nameplate.fromJson(json['nameplate'] as Map<String, dynamic>)
          : null,
      isFollowed: json['is_followed'] as bool? ?? false,
      topPhoto: json['top_photo'] as String?,
      topPhotoV2: json['top_photo_v2'] != null
          ? TopPhotoV2.fromJson(json['top_photo_v2'] as Map<String, dynamic>)
          : null,
      liveRoom: json['live_room'] != null
          ? LiveRoom.fromJson(json['live_room'] as Map<String, dynamic>)
          : null,
      birthday: json['birthday'] as String?,
      school: json['school'] != null
          ? School.fromJson(json['school'] as Map<String, dynamic>)
          : null,
      profession: json['profession'] != null
          ? Profession.fromJson(json['profession'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isSeniorMember: json['is_senior_member'] as int? ?? 0,
    );
  }

  /// User mid
  final int mid;

  /// Nickname
  final String name;

  /// Gender: male/female/secret
  final String sex;

  /// Avatar URL
  final String face;

  /// Signature
  final String sign;

  /// Level 0-6
  final int level;

  /// Whether NFT avatar: 0 no, 1 yes
  final int faceNft;

  /// User permission level
  final int rank;

  /// Ban status: 0 normal, 1 banned
  final int silence;

  /// Coin count
  final int coins;

  /// Has fans badge
  final bool fansBadge;

  /// Fans medal info
  final FansMedal? fansMedal;

  /// Official verification info
  final OfficialInfo? official;

  /// VIP info
  final VipInfo? vip;

  /// Avatar frame info
  final Pendant? pendant;

  /// Medal info
  final Nameplate? nameplate;

  /// Whether followed this user
  final bool isFollowed;

  /// Top photo URL
  final String? topPhoto;

  /// Top photo V2 info
  final TopPhotoV2? topPhotoV2;

  /// Live room info
  final LiveRoom? liveRoom;

  /// Birthday MM-DD
  final String? birthday;

  /// School info
  final School? school;

  /// Profession info
  final Profession? profession;

  /// Personal tags
  final List<String>? tags;

  /// Whether senior member: 0 no, 1 yes
  final int isSeniorMember;

  /// Whether the user is banned
  bool get isBanned => silence == 1;

  /// Whether the user is verified
  bool get isVerified => official?.type != null && official!.type >= 0;

  /// Whether the user is VIP
  bool get isVip => vip?.status == 1;
}

/// Fans medal info
class FansMedal {
  const FansMedal({
    required this.show,
    required this.wear,
    this.medal,
  });

  factory FansMedal.fromJson(Map<String, dynamic> json) {
    return FansMedal(
      show: json['show'] as bool? ?? false,
      wear: json['wear'] as bool? ?? false,
      medal: json['medal'] != null
          ? Medal.fromJson(json['medal'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool show;
  final bool wear;
  final Medal? medal;
}

/// Medal details
class Medal {
  const Medal({
    required this.uid,
    required this.targetId,
    required this.medalId,
    required this.level,
    required this.medalName,
    required this.medalColor,
    required this.intimacy,
    required this.nextIntimacy,
    required this.wearingStatus,
  });

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      uid: json['uid'] as int? ?? 0,
      targetId: json['target_id'] as int? ?? 0,
      medalId: json['medal_id'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
      medalName: json['medal_name'] as String? ?? '',
      medalColor: json['medal_color'] as int? ?? 0,
      intimacy: json['intimacy'] as int? ?? 0,
      nextIntimacy: json['next_intimacy'] as int? ?? 0,
      wearingStatus: json['wearing_status'] as int? ?? 0,
    );
  }

  final int uid;
  final int targetId;
  final int medalId;
  final int level;
  final String medalName;
  final int medalColor;
  final int intimacy;
  final int nextIntimacy;
  final int wearingStatus;
}

/// Official verification info
class OfficialInfo {
  const OfficialInfo({
    required this.role,
    required this.title,
    required this.desc,
    required this.type,
  });

  factory OfficialInfo.fromJson(Map<String, dynamic> json) {
    return OfficialInfo(
      role: json['role'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      type: json['type'] as int? ?? -1,
    );
  }

  /// Verification type
  final int role;

  /// Verification info
  final String title;

  /// Verification note
  final String desc;

  /// Whether verified: -1 none, 0 personal, 1 organization, 2 craftsman, 3 official
  final int type;

  /// Whether personal verified
  bool get isPersonalVerified => type == 0;

  /// Whether organization verified
  bool get isOrgVerified => type == 1;
}

/// VIP info
class VipInfo {
  const VipInfo({
    required this.type,
    required this.status,
    required this.dueDate,
    this.vipPayType = 0,
    this.themeType = 0,
    this.label,
    this.avatarSubscript = 0,
    this.nicknameColor,
    this.avatarSubscriptUrl,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) {
    return VipInfo(
      type: json['type'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      dueDate: json['due_date'] as int? ?? 0,
      vipPayType: json['vip_pay_type'] as int? ?? 0,
      themeType: json['theme_type'] as int? ?? 0,
      label: json['label'] != null
          ? VipLabel.fromJson(json['label'] as Map<String, dynamic>)
          : null,
      avatarSubscript: json['avatar_subscript'] as int? ?? 0,
      nicknameColor: json['nickname_color'] as String?,
      avatarSubscriptUrl: json['avatar_subscript_url'] as String?,
    );
  }

  /// VIP type: 0 none, 1 monthly, 2 annual+
  final int type;

  /// VIP status: 0 none, 1 active
  final int status;

  /// VIP expiry date (milliseconds timestamp)
  final int dueDate;

  /// Payment type: 0 non-auto-renew, 1 auto-renew
  final int vipPayType;

  /// Theme type
  final int themeType;

  /// VIP label
  final VipLabel? label;

  /// Show VIP icon: 0 no, 1 yes
  final int avatarSubscript;

  /// VIP nickname color
  final String? nicknameColor;

  /// VIP avatar subscript URL
  final String? avatarSubscriptUrl;

  /// Whether VIP is active
  bool get isVip => status == 1;

  /// Whether annual VIP
  bool get isAnnualVip => type == 2;
}

/// VIP label
class VipLabel {
  const VipLabel({
    this.path,
    this.text,
    this.labelTheme,
    this.textColor,
    this.bgStyle = 0,
    this.bgColor,
    this.borderColor,
    this.imgLabelUriHansStatic,
    this.imgLabelUriHantStatic,
  });

  factory VipLabel.fromJson(Map<String, dynamic> json) {
    return VipLabel(
      path: json['path'] as String?,
      text: json['text'] as String?,
      labelTheme: json['label_theme'] as String?,
      textColor: json['text_color'] as String?,
      bgStyle: json['bg_style'] as int? ?? 0,
      bgColor: json['bg_color'] as String?,
      borderColor: json['border_color'] as String?,
      imgLabelUriHansStatic: json['img_label_uri_hans_static'] as String?,
      imgLabelUriHantStatic: json['img_label_uri_hant_static'] as String?,
    );
  }

  final String? path;
  final String? text;
  final String? labelTheme;
  final String? textColor;
  final int bgStyle;
  final String? bgColor;
  final String? borderColor;
  final String? imgLabelUriHansStatic;
  final String? imgLabelUriHantStatic;
}

/// Avatar frame info
class Pendant {
  const Pendant({
    required this.pid,
    this.name,
    this.image,
    this.expire = 0,
    this.imageEnhance,
    this.imageEnhanceFrame,
  });

  factory Pendant.fromJson(Map<String, dynamic> json) {
    return Pendant(
      pid: json['pid'] as int? ?? 0,
      name: json['name'] as String?,
      image: json['image'] as String?,
      expire: json['expire'] as int? ?? 0,
      imageEnhance: json['image_enhance'] as String?,
      imageEnhanceFrame: json['image_enhance_frame'] as String?,
    );
  }

  final int pid;
  final String? name;
  final String? image;
  final int expire;
  final String? imageEnhance;
  final String? imageEnhanceFrame;
}

/// Nameplate/medal info
class Nameplate {
  const Nameplate({
    required this.nid,
    this.name,
    this.image,
    this.imageSmall,
    this.level,
    this.condition,
  });

  factory Nameplate.fromJson(Map<String, dynamic> json) {
    return Nameplate(
      nid: json['nid'] as int? ?? 0,
      name: json['name'] as String?,
      image: json['image'] as String?,
      imageSmall: json['image_small'] as String?,
      level: json['level'] as String?,
      condition: json['condition'] as String?,
    );
  }

  final int nid;
  final String? name;
  final String? image;
  final String? imageSmall;
  final String? level;
  final String? condition;
}

/// Top photo V2 info
class TopPhotoV2 {
  const TopPhotoV2({
    this.l200hImg,
    this.lImg,
    this.sid = 0,
  });

  factory TopPhotoV2.fromJson(Map<String, dynamic> json) {
    return TopPhotoV2(
      l200hImg: json['l_200h_img'] as String?,
      lImg: json['l_img'] as String?,
      sid: json['sid'] as int? ?? 0,
    );
  }

  /// 200px height top photo URL
  final String? l200hImg;

  /// Original top photo URL
  final String? lImg;

  final int sid;
}

/// Live room info
class LiveRoom {
  const LiveRoom({
    required this.roomStatus,
    required this.liveStatus,
    this.url,
    this.title,
    this.cover,
    this.roomId = 0,
    this.roundStatus = 0,
    this.broadcastType = 0,
    this.watchedShow,
  });

  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    return LiveRoom(
      roomStatus: json['roomStatus'] as int? ?? 0,
      liveStatus: json['liveStatus'] as int? ?? 0,
      url: json['url'] as String?,
      title: json['title'] as String?,
      cover: json['cover'] as String?,
      roomId: json['roomid'] as int? ?? 0,
      roundStatus: json['roundStatus'] as int? ?? 0,
      broadcastType: json['broadcast_type'] as int? ?? 0,
      watchedShow: json['watched_show'] != null
          ? WatchedShow.fromJson(json['watched_show'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Room status: 0 no room, 1 has room
  final int roomStatus;

  /// Live status: 0 not live, 1 live
  final int liveStatus;

  final String? url;
  final String? title;
  final String? cover;
  final int roomId;
  final int roundStatus;
  final int broadcastType;
  final WatchedShow? watchedShow;

  /// Whether has room
  bool get hasRoom => roomStatus == 1;

  /// Whether is live
  bool get isLive => liveStatus == 1;
}

/// Watched show info
class WatchedShow {
  const WatchedShow({
    this.switchFlag = false,
    this.num = 0,
    this.textSmall,
    this.textLarge,
    this.icon,
  });

  factory WatchedShow.fromJson(Map<String, dynamic> json) {
    return WatchedShow(
      switchFlag: json['switch'] as bool? ?? false,
      num: json['num'] as int? ?? 0,
      textSmall: json['text_small'] as String?,
      textLarge: json['text_large'] as String?,
      icon: json['icon'] as String?,
    );
  }

  final bool switchFlag;
  final int num;
  final String? textSmall;
  final String? textLarge;
  final String? icon;
}

/// School info
class School {
  const School({this.name});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(name: json['name'] as String?);
  }

  final String? name;
}

/// Profession info
class Profession {
  const Profession({
    this.name,
    this.department,
    this.title,
    this.isShow = 0,
  });

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      name: json['name'] as String?,
      department: json['department'] as String?,
      title: json['title'] as String?,
      isShow: json['is_show'] as int? ?? 0,
    );
  }

  final String? name;
  final String? department;
  final String? title;
  final int isShow;
}
