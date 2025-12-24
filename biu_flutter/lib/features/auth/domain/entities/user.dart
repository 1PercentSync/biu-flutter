/// User information entity
class User {
  /// User ID (mid)
  final int mid;

  /// Username
  final String uname;

  /// Avatar URL
  final String face;

  /// Whether user is logged in
  final bool isLogin;

  /// User level (1-6)
  final int level;

  /// VIP status: 0-none, 1-active
  final int vipStatus;

  /// VIP type: 0-none, 1-monthly, 2-annual+
  final int vipType;

  /// VIP due date (milliseconds timestamp)
  final int vipDueDate;

  /// Current coin count
  final double money;

  /// B-coin balance
  final double bcoinBalance;

  /// Whether email is verified
  final bool emailVerified;

  /// Whether mobile is verified
  final bool mobileVerified;

  /// Official verification role
  final int officialRole;

  /// Official verification title
  final String officialTitle;

  const User({
    required this.mid,
    required this.uname,
    required this.face,
    required this.isLogin,
    this.level = 0,
    this.vipStatus = 0,
    this.vipType = 0,
    this.vipDueDate = 0,
    this.money = 0,
    this.bcoinBalance = 0,
    this.emailVerified = false,
    this.mobileVerified = false,
    this.officialRole = 0,
    this.officialTitle = '',
  });

  /// Check if user has VIP
  bool get isVip => vipStatus == 1;

  /// Check if user is annual VIP or above
  bool get isAnnualVip => vipType >= 2;

  /// Create a copy with updated fields
  User copyWith({
    int? mid,
    String? uname,
    String? face,
    bool? isLogin,
    int? level,
    int? vipStatus,
    int? vipType,
    int? vipDueDate,
    double? money,
    double? bcoinBalance,
    bool? emailVerified,
    bool? mobileVerified,
    int? officialRole,
    String? officialTitle,
  }) {
    return User(
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      face: face ?? this.face,
      isLogin: isLogin ?? this.isLogin,
      level: level ?? this.level,
      vipStatus: vipStatus ?? this.vipStatus,
      vipType: vipType ?? this.vipType,
      vipDueDate: vipDueDate ?? this.vipDueDate,
      money: money ?? this.money,
      bcoinBalance: bcoinBalance ?? this.bcoinBalance,
      emailVerified: emailVerified ?? this.emailVerified,
      mobileVerified: mobileVerified ?? this.mobileVerified,
      officialRole: officialRole ?? this.officialRole,
      officialTitle: officialTitle ?? this.officialTitle,
    );
  }

  @override
  String toString() => 'User(mid: $mid, uname: $uname, isLogin: $isLogin)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.mid == mid;
  }

  @override
  int get hashCode => mid.hashCode;
}
