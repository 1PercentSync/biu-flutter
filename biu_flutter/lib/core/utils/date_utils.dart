import 'package:intl/intl.dart';

/// Utility class for date formatting operations.
///
/// Provides consistent date formatting across the app.
class DateUtils {
  DateUtils._();

  /// Format a date as a relative string (今天, 昨天, X天前, etc.)
  ///
  /// Returns:
  /// - "今天" if the date is today
  /// - "昨天" if the date is yesterday
  /// - "X天前" if within the last 7 days
  /// - "MM-dd" if in the same year
  /// - "yyyy-MM-dd" for older dates
  ///
  /// Source: Extracted from features/user_profile/presentation/widgets/video_post_card.dart
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0 && date.day == now.day) {
      return '今天';
    } else if (diff.inDays == 1 || (diff.inDays == 0 && date.day != now.day)) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (date.year == now.year) {
      return DateFormat('MM-dd').format(date);
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format a timestamp (seconds since epoch) as a relative string.
  ///
  /// Convenience method for API responses that return timestamps.
  static String formatRelativeFromTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatRelative(date);
  }

  /// Format a date as a moment-style relative string (刚刚, X分钟前, X小时前, etc.)
  ///
  /// More granular than [formatRelative], suitable for feeds and timelines.
  /// Matches moment.js fromNow() behavior used in source project.
  ///
  /// Returns:
  /// - "刚刚" if less than 1 minute ago
  /// - "X分钟前" if less than 1 hour ago
  /// - "X小时前" if less than 1 day ago
  /// - "X天前" if less than 7 days ago
  /// - "MM-dd" for older dates in the same year
  /// - "yyyy-MM-dd" for dates in previous years
  ///
  /// Source: moment.js fromNow() - biu/src/components/dynamic-feed/item.tsx
  static String formatMomentStyle(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (date.year == now.year) {
      return DateFormat('MM-dd').format(date);
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format a timestamp (seconds since epoch) as a moment-style relative string.
  ///
  /// Convenience method for API responses that return timestamps.
  static String formatMomentStyleFromTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatMomentStyle(date);
  }

  /// Format a date as "MM-dd HH:mm" for recent items.
  static String formatDateTime(DateTime date) {
    return DateFormat('MM-dd HH:mm').format(date);
  }

  /// Format a date as full date string "yyyy-MM-dd".
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format a date as full date time string "yyyy-MM-dd HH:mm:ss".
  static String formatFullDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Format a timestamp as time only "HH:mm".
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
