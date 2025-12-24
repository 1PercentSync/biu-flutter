import '../../domain/entities/user.dart';

/// Response from /x/web-interface/nav API
class UserInfoResponse {

  const UserInfoResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserInfoData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
  final int code;
  final String message;
  final UserInfoData? data;

  bool get isSuccess => code == 0;
  bool get isLoggedIn => isSuccess && (data?.isLogin ?? false);
}

/// User info data from API
class UserInfoData {

  const UserInfoData({
    required this.isLogin,
    required this.mid,
    required this.uname,
    required this.face,
    required this.emailVerified,
    required this.mobileVerified,
    required this.levelInfo,
    required this.money,
    required this.vipStatus,
    required this.vipType,
    required this.vipDueDate,
    required this.official,
    required this.wallet,
    required this.wbiImg,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData(
      isLogin: json['isLogin'] as bool? ?? false,
      mid: json['mid'] as int? ?? 0,
      uname: json['uname'] as String? ?? '',
      face: json['face'] as String? ?? '',
      emailVerified: json['email_verified'] as int? ?? 0,
      mobileVerified: json['mobile_verified'] as int? ?? 0,
      levelInfo: json['level_info'] != null
          ? LevelInfo.fromJson(json['level_info'] as Map<String, dynamic>)
          : const LevelInfo(currentLevel: 0),
      money: (json['money'] as num?)?.toDouble() ?? 0,
      vipStatus: json['vipStatus'] as int? ?? 0,
      vipType: json['vipType'] as int? ?? 0,
      vipDueDate: json['vipDueDate'] as int? ?? 0,
      official: json['official'] != null
          ? Official.fromJson(json['official'] as Map<String, dynamic>)
          : const Official(role: 0, title: ''),
      wallet: json['wallet'] != null
          ? Wallet.fromJson(json['wallet'] as Map<String, dynamic>)
          : const Wallet(bcoinBalance: 0),
      wbiImg: json['wbi_img'] != null
          ? WbiImg.fromJson(json['wbi_img'] as Map<String, dynamic>)
          : const WbiImg(imgUrl: '', subUrl: ''),
    );
  }
  final bool isLogin;
  final int mid;
  final String uname;
  final String face;
  final int emailVerified;
  final int mobileVerified;
  final LevelInfo levelInfo;
  final double money;
  final int vipStatus;
  final int vipType;
  final int vipDueDate;
  final Official official;
  final Wallet wallet;
  final WbiImg wbiImg;

  /// Convert to domain entity
  User toEntity() {
    return User(
      mid: mid,
      uname: uname,
      face: face,
      isLogin: isLogin,
      level: levelInfo.currentLevel,
      vipStatus: vipStatus,
      vipType: vipType,
      vipDueDate: vipDueDate,
      money: money,
      bcoinBalance: wallet.bcoinBalance,
      emailVerified: emailVerified == 1,
      mobileVerified: mobileVerified == 1,
      officialRole: official.role,
      officialTitle: official.title,
    );
  }
}

class LevelInfo {

  const LevelInfo({required this.currentLevel});

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      currentLevel: json['current_level'] as int? ?? 0,
    );
  }
  final int currentLevel;
}

class Official {

  const Official({required this.role, required this.title});

  factory Official.fromJson(Map<String, dynamic> json) {
    return Official(
      role: json['role'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
  final int role;
  final String title;
}

class Wallet {

  const Wallet({required this.bcoinBalance});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      bcoinBalance: (json['bcoin_balance'] as num?)?.toDouble() ?? 0,
    );
  }
  final double bcoinBalance;
}

class WbiImg {

  const WbiImg({required this.imgUrl, required this.subUrl});

  factory WbiImg.fromJson(Map<String, dynamic> json) {
    return WbiImg(
      imgUrl: json['img_url'] as String? ?? '',
      subUrl: json['sub_url'] as String? ?? '',
    );
  }
  final String imgUrl;
  final String subUrl;
}
