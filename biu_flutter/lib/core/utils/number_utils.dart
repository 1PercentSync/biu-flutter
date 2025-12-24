/// Utility functions for number formatting
class NumberUtils {
  NumberUtils._();

  /// Format large numbers with K, M, B suffixes
  /// e.g., 1234 -> "1.2K", 1234567 -> "1.2M"
  static String formatCompact(int? number) {
    if (number == null) return '0';
    if (number < 1000) return number.toString();
    if (number < 10000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    if (number < 100000000) {
      // Use 万 (wan) for Chinese convention
      final wan = number / 10000;
      if (wan >= 10) {
        return '${wan.round()}万';
      }
      return '${wan.toStringAsFixed(1)}万';
    }
    // Use 亿 (yi) for very large numbers
    final yi = number / 100000000;
    return '${yi.toStringAsFixed(1)}亿';
  }

  /// Format number with thousands separator
  /// e.g., 1234567 -> "1,234,567"
  static String formatWithSeparator(int? number) {
    if (number == null) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  /// Format percentage
  /// e.g., 0.1234 -> "12.3%"
  static String formatPercentage(double? value, {int decimals = 1}) {
    if (value == null) return '0%';
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Clamp a value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
