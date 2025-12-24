/// Utility functions for formatting values.
class FormatUtils {
  FormatUtils._();

  /// Format a count number to a human-readable string.
  ///
  /// Examples:
  /// - 1234 -> "1234"
  /// - 12345 -> "1.2万"
  /// - 123456789 -> "1.2亿"
  static String formatCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}
