import 'package:biu_flutter/core/extensions/datetime_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExtensions', () {
    group('toDateString', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 1, 15);
        expect(date.toDateString(), '2024-01-15');
      });

      test('pads single digit month and day', () {
        final date = DateTime(2024, 3, 5);
        expect(date.toDateString(), '2024-03-05');
      });
    });

    group('toDateTimeString', () {
      test('formats date and time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
        expect(dateTime.toDateTimeString(), '2024-01-15 14:30:45');
      });

      test('pads single digit values', () {
        final dateTime = DateTime(2024, 3, 5, 8, 5, 9);
        expect(dateTime.toDateTimeString(), '2024-03-05 08:05:09');
      });
    });

    group('toRelativeString', () {
      test('returns "Just now" for recent times', () {
        final now = DateTime.now();
        final recent = now.subtract(const Duration(seconds: 30));
        expect(recent.toRelativeString(), 'Just now');
      });

      test('returns minutes ago', () {
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        expect(fiveMinutesAgo.toRelativeString(), '5 minute(s) ago');
      });

      test('returns hours ago', () {
        final now = DateTime.now();
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(twoHoursAgo.toRelativeString(), '2 hour(s) ago');
      });

      test('returns days ago', () {
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(threeDaysAgo.toRelativeString(), '3 day(s) ago');
      });

      test('returns months ago', () {
        final now = DateTime.now();
        final twoMonthsAgo = now.subtract(const Duration(days: 60));
        expect(twoMonthsAgo.toRelativeString(), '2 month(s) ago');
      });

      test('returns years ago', () {
        final now = DateTime.now();
        final twoYearsAgo = now.subtract(const Duration(days: 730));
        expect(twoYearsAgo.toRelativeString(), '2 year(s) ago');
      });
    });
  });

  group('UnixTimestampExtensions', () {
    group('toDateTime', () {
      test('converts Unix timestamp to DateTime', () {
        // Use a known timestamp and verify conversion works
        const timestamp = 1704067200; // Jan 1, 2024 00:00:00 UTC
        final dateTime = timestamp.toDateTime();
        // Verify it's the same instant (accounting for local timezone)
        expect(dateTime.millisecondsSinceEpoch, timestamp * 1000);
      });

      test('preserves timestamp value', () {
        const timestamp = 1609459200; // Jan 1, 2021 00:00:00 UTC
        final dateTime = timestamp.toDateTime();
        expect(dateTime.millisecondsSinceEpoch ~/ 1000, timestamp);
      });
    });

    group('toDateString', () {
      test('converts Unix timestamp to date string', () {
        // Create a timestamp from a known local DateTime
        final knownDate = DateTime(2024, 6, 15);
        final timestamp = knownDate.millisecondsSinceEpoch ~/ 1000;
        expect(timestamp.toDateString(), '2024-06-15');
      });
    });

    group('toDateTimeFromMillis', () {
      test('converts millisecond timestamp to DateTime', () {
        // Use DateTime to get a known millisecond timestamp
        final knownDateTime = DateTime(2024, 3, 15, 12, 30);
        final timestamp = knownDateTime.millisecondsSinceEpoch;
        final result = timestamp.toDateTimeFromMillis();
        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
      });
    });
  });
}
