/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format duration as mm:ss or hh:mm:ss
  String toFormattedString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }
}

/// Extension methods for int (as seconds)
extension SecondsExtensions on int {
  /// Convert seconds to Duration
  Duration get seconds => Duration(seconds: this);

  /// Format seconds as mm:ss or hh:mm:ss
  String toFormattedDuration() {
    return Duration(seconds: this).toFormattedString();
  }
}

/// Extension methods for double (as seconds)
extension DoubleSecondsExtensions on double {
  /// Convert seconds to Duration
  Duration get seconds => Duration(milliseconds: (this * 1000).round());

  /// Format seconds as mm:ss or hh:mm:ss
  String toFormattedDuration() {
    return Duration(milliseconds: (this * 1000).round()).toFormattedString();
  }
}
