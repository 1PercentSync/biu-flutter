import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('stripHtml', () {
      test('returns empty string for empty input', () {
        expect(''.stripHtml(), '');
      });

      test('returns string unchanged if no HTML tags', () {
        expect('Hello World'.stripHtml(), 'Hello World');
      });

      test('removes simple HTML tags', () {
        expect('<b>Bold</b>'.stripHtml(), 'Bold');
        expect('<em>Emphasis</em>'.stripHtml(), 'Emphasis');
      });

      test('removes nested HTML tags', () {
        expect('<div><span>Nested</span></div>'.stripHtml(), 'Nested');
      });

      test('removes tags with attributes', () {
        expect('<a href="link">Link</a>'.stripHtml(), 'Link');
        expect('<span class="highlight">Text</span>'.stripHtml(), 'Text');
      });

      test('handles Bilibili search highlight tags', () {
        expect(
          '<em class="keyword">搜索</em>关键词'.stripHtml(),
          '搜索关键词',
        );
      });
    });

    group('toHttps', () {
      test('returns empty string for empty input', () {
        expect(''.toHttps(), '');
      });

      test('adds https: to protocol-relative URLs', () {
        expect('//example.com'.toHttps(), 'https://example.com');
      });

      test('converts http to https', () {
        expect('http://example.com'.toHttps(), 'https://example.com');
      });

      test('preserves https URLs', () {
        expect('https://example.com'.toHttps(), 'https://example.com');
      });
    });

    group('truncate', () {
      test('returns string unchanged if shorter than maxLength', () {
        expect('Hello'.truncate(10), 'Hello');
      });

      test('truncates and adds ellipsis', () {
        expect('Hello World'.truncate(8), 'Hello...');
      });

      test('supports custom ellipsis', () {
        expect('Hello World'.truncate(9, ellipsis: '…'), 'Hello Wo…');
      });
    });

    group('isBvid', () {
      test('returns true for valid BV IDs', () {
        expect('BV1xx411c7mD'.isBvid, true);
        expect('BV1ab4y1E7DK'.isBvid, true);
      });

      test('returns false for invalid BV IDs', () {
        expect('av12345'.isBvid, false);
        expect('bv1xx411c7mD'.isBvid, false); // lowercase bv
        expect('BV'.isBvid, false);
        expect(''.isBvid, false);
      });
    });

    group('isAvid', () {
      test('returns true for valid AV IDs', () {
        expect('av12345'.isAvid, true);
        expect('AV12345'.isAvid, true);
        expect('Av12345'.isAvid, true);
      });

      test('returns false for invalid AV IDs', () {
        expect('BV1xx411c7mD'.isAvid, false);
        expect('av'.isAvid, false);
        expect('avABC'.isAvid, false);
        expect(''.isAvid, false);
      });
    });

    group('avidNumber', () {
      test('extracts number from AV ID', () {
        expect('av12345'.avidNumber, 12345);
        expect('AV67890'.avidNumber, 67890);
      });

      test('returns null for non-AV strings', () {
        expect('BV1xx411c7mD'.avidNumber, null);
        expect('not-av-id'.avidNumber, null);
      });
    });
  });

  group('NullableStringExtensions', () {
    group('isNullOrEmpty', () {
      test('returns true for null', () {
        const String? nullString = null;
        expect(nullString.isNullOrEmpty, true);
      });

      test('returns true for empty string', () {
        expect(''.isNullOrEmpty, true);
      });

      test('returns false for non-empty string', () {
        expect('hello'.isNullOrEmpty, false);
      });
    });

    group('isNotNullOrEmpty', () {
      test('returns false for null', () {
        const String? nullString = null;
        expect(nullString.isNotNullOrEmpty, false);
      });

      test('returns false for empty string', () {
        expect(''.isNotNullOrEmpty, false);
      });

      test('returns true for non-empty string', () {
        expect('hello'.isNotNullOrEmpty, true);
      });
    });

    group('orEmpty', () {
      test('returns empty string for null', () {
        const String? nullString = null;
        expect(nullString.orEmpty, '');
      });

      test('returns the string itself for non-null', () {
        expect('hello'.orEmpty, 'hello');
      });
    });
  });
}
