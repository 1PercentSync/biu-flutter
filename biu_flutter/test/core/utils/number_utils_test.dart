import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/utils/number_utils.dart';

void main() {
  group('NumberUtils', () {
    group('formatCompact', () {
      test('returns 0 for null input', () {
        expect(NumberUtils.formatCompact(null), '0');
      });

      test('returns number as-is for values under 1000', () {
        expect(NumberUtils.formatCompact(0), '0');
        expect(NumberUtils.formatCompact(1), '1');
        expect(NumberUtils.formatCompact(999), '999');
      });

      test('formats thousands with K suffix', () {
        expect(NumberUtils.formatCompact(1000), '1.0K');
        expect(NumberUtils.formatCompact(1234), '1.2K');
        expect(NumberUtils.formatCompact(9999), '10.0K');
      });

      test('formats ten-thousands with 万 suffix', () {
        expect(NumberUtils.formatCompact(10000), '1.0万');
        expect(NumberUtils.formatCompact(12345), '1.2万');
        expect(NumberUtils.formatCompact(100000), '10万');
        expect(NumberUtils.formatCompact(1234567), '123万');
      });

      test('formats hundred-millions with 亿 suffix', () {
        expect(NumberUtils.formatCompact(100000000), '1.0亿');
        expect(NumberUtils.formatCompact(123456789), '1.2亿');
        expect(NumberUtils.formatCompact(999999999), '10.0亿');
      });
    });

    group('formatWithSeparator', () {
      test('returns 0 for null input', () {
        expect(NumberUtils.formatWithSeparator(null), '0');
      });

      test('returns number as-is for values under 1000', () {
        expect(NumberUtils.formatWithSeparator(0), '0');
        expect(NumberUtils.formatWithSeparator(999), '999');
      });

      test('adds thousand separators correctly', () {
        expect(NumberUtils.formatWithSeparator(1000), '1,000');
        expect(NumberUtils.formatWithSeparator(1234567), '1,234,567');
        expect(NumberUtils.formatWithSeparator(1234567890), '1,234,567,890');
      });
    });

    group('formatPercentage', () {
      test('returns 0% for null input', () {
        expect(NumberUtils.formatPercentage(null), '0%');
      });

      test('formats percentages correctly', () {
        expect(NumberUtils.formatPercentage(0.0), '0.0%');
        expect(NumberUtils.formatPercentage(0.1234), '12.3%');
        expect(NumberUtils.formatPercentage(0.5), '50.0%');
        expect(NumberUtils.formatPercentage(1.0), '100.0%');
      });

      test('respects decimals parameter', () {
        expect(NumberUtils.formatPercentage(0.1234, decimals: 0), '12%');
        expect(NumberUtils.formatPercentage(0.1234, decimals: 2), '12.34%');
      });
    });

    group('clamp', () {
      test('clamps int values correctly', () {
        expect(NumberUtils.clamp(5, 0, 10), 5);
        expect(NumberUtils.clamp(-5, 0, 10), 0);
        expect(NumberUtils.clamp(15, 0, 10), 10);
      });

      test('clamps double values correctly', () {
        expect(NumberUtils.clamp(0.5, 0.0, 1.0), 0.5);
        expect(NumberUtils.clamp(-0.5, 0.0, 1.0), 0.0);
        expect(NumberUtils.clamp(1.5, 0.0, 1.0), 1.0);
      });
    });
  });
}
