import 'package:intl/intl.dart';

/// Extension methods for DateTime.
///
/// Provides date formatting utilities for displaying timestamps.
///
/// Source: biu/src/common/utils/time.ts (formatSecondsToDate, formatMillisecond)
extension DateTimeExtensions on DateTime {
  /// Format as date string (YYYY-MM-DD)
  String toDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format as date time string (YYYY-MM-DD HH:mm:ss)
  String toDateTimeString() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  /// Format as relative time string (e.g., "2 hours ago")
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

/// Extension methods for int (as Unix timestamp).
///
/// Converts Unix timestamps to DateTime and formatted strings.
///
/// Source: biu/src/common/utils/time.ts#formatSecondsToDate
extension UnixTimestampExtensions on int {
  /// Convert Unix timestamp (seconds) to DateTime
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }

  /// Convert Unix timestamp (seconds) to date string
  String toDateString() {
    return toDateTime().toDateString();
  }

  /// Convert Unix timestamp (milliseconds) to DateTime
  DateTime toDateTimeFromMillis() {
    return DateTime.fromMillisecondsSinceEpoch(this);
  }

  /// Convert Unix timestamp (milliseconds) to date string
  String toDateStringFromMillis() {
    return toDateTimeFromMillis().toDateString();
  }
}
