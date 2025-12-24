import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/extensions/duration_extensions.dart';

void main() {
  group('DurationExtensions', () {
    group('toFormattedString', () {
      test('formats seconds only', () {
        expect(const Duration(seconds: 5).toFormattedString(), '00:05');
        expect(const Duration(seconds: 30).toFormattedString(), '00:30');
      });

      test('formats minutes and seconds', () {
        expect(const Duration(minutes: 1, seconds: 5).toFormattedString(), '01:05');
        expect(const Duration(minutes: 10, seconds: 30).toFormattedString(), '10:30');
        expect(const Duration(minutes: 59, seconds: 59).toFormattedString(), '59:59');
      });

      test('formats hours, minutes, and seconds', () {
        expect(
          const Duration(hours: 1, minutes: 5, seconds: 10).toFormattedString(),
          '01:05:10',
        );
        expect(
          const Duration(hours: 10, minutes: 30, seconds: 45).toFormattedString(),
          '10:30:45',
        );
      });

      test('handles zero duration', () {
        expect(const Duration().toFormattedString(), '00:00');
      });
    });

    group('formatted getter', () {
      test('returns same result as toFormattedString', () {
        const duration = Duration(minutes: 3, seconds: 25);
        expect(duration.formatted, duration.toFormattedString());
      });
    });
  });

  group('SecondsExtensions', () {
    group('seconds getter', () {
      test('converts int to Duration', () {
        expect(60.seconds, const Duration(seconds: 60));
        expect(3600.seconds, const Duration(hours: 1));
      });
    });

    group('toFormattedDuration', () {
      test('formats seconds as duration string', () {
        expect(65.toFormattedDuration(), '01:05');
        expect(3661.toFormattedDuration(), '01:01:01');
      });
    });
  });

  group('DoubleSecondsExtensions', () {
    group('seconds getter', () {
      test('converts double to Duration', () {
        expect(1.5.seconds, const Duration(milliseconds: 1500));
        expect(60.5.seconds, const Duration(milliseconds: 60500));
      });
    });

    group('toFormattedDuration', () {
      test('formats double seconds as duration string', () {
        expect(65.5.toFormattedDuration(), '01:05'); // 65500ms -> 65s
        expect(90.0.toFormattedDuration(), '01:30');
        // 65.999 seconds = 65999ms -> Duration truncates to 65s
        expect(65.999.toFormattedDuration(), '01:05');
      });
    });
  });
}
