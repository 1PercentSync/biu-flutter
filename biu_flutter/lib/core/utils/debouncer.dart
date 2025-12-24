import 'dart:async';

/// A utility class for debouncing function calls
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

/// A utility class for throttling function calls
class Throttler {
  Throttler({this.duration = const Duration(milliseconds: 300)});

  /// The minimum duration between calls
  final Duration duration;

  DateTime? _lastCall;

  /// Run the callback if enough time has passed since the last call
  void run(void Function() callback) {
    final now = DateTime.now();
    if (_lastCall == null ||
        now.difference(_lastCall!) >= duration) {
      _lastCall = now;
      callback();
    }
  }

  /// Reset the throttler, allowing the next call to execute immediately
  void reset() {
    _lastCall = null;
  }
}
