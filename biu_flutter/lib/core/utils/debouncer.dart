import 'dart:async';

/// A utility class for debouncing function calls.
///
/// Delays execution until a specified duration has passed without new calls.
/// Commonly used for search input to avoid excessive API requests.
///
/// Source: Flutter-only (standard debounce pattern)
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// The delay duration before executing the callback
  final Duration delay;

  Timer? _timer;

  /// Run the callback after the delay
  /// If called again before the delay expires, the timer is reset
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer and cancel any pending callback
  void dispose() {
    cancel();
  }

  /// Check if there's a pending callback
  bool get isPending => _timer?.isActive ?? false;
}
