/// VIP type constants for Bilibili membership status.
///
/// Source: biu/src/common/constants/vip.ts
enum VipType {
  /// No VIP membership
  none(0),

  /// Monthly VIP membership
  monthVip(1),

  /// Annual VIP membership (and above)
  yearVip(2);

  const VipType(this.value);

  /// The numeric value used in API responses
  final int value;

  /// Create VipType from numeric value
  static VipType fromValue(int value) {
    return VipType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VipType.none,
    );
  }

  /// Check if this VIP type is annual or above
  bool get isAnnualOrAbove => value >= yearVip.value;
}
