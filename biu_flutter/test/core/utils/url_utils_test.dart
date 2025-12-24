import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    group('formatProtocol', () {
      test('returns empty string for null or empty input', () {
        expect(UrlUtils.formatProtocol(null), '');
        expect(UrlUtils.formatProtocol(''), '');
      });

      test('adds https: to protocol-relative URLs', () {
        expect(
          UrlUtils.formatProtocol('//example.com/path'),
          'https://example.com/path',
        );
      });

      test('converts http to https', () {
        expect(
          UrlUtils.formatProtocol('http://example.com/path'),
          'https://example.com/path',
        );
      });

      test('preserves existing https URLs', () {
        expect(
          UrlUtils.formatProtocol('https://example.com/path'),
          'https://example.com/path',
        );
      });
    });

    group('toWebp', () {
      test('returns empty string for null or empty input', () {
        expect(UrlUtils.toWebp(null), '');
        expect(UrlUtils.toWebp(''), '');
      });

      test('adds @.webp suffix', () {
        expect(
          UrlUtils.toWebp('https://example.com/image.jpg'),
          'https://example.com/image.jpg@.webp',
        );
      });

      test('adds width and height parameters', () {
        expect(
          UrlUtils.toWebp('https://example.com/image.jpg', width: 100, height: 100),
          'https://example.com/image.jpg@100w_100h.webp',
        );
      });

      test('adds width only parameter', () {
        expect(
          UrlUtils.toWebp('https://example.com/image.jpg', width: 200),
          'https://example.com/image.jpg@200w.webp',
        );
      });

      test('adds height only parameter', () {
        expect(
          UrlUtils.toWebp('https://example.com/image.jpg', height: 150),
          'https://example.com/image.jpg@150h.webp',
        );
      });

      test('removes existing format suffix before adding new one', () {
        expect(
          UrlUtils.toWebp('https://example.com/image.jpg@200w_200h.jpg', width: 100),
          'https://example.com/image.jpg@100w.webp',
        );
      });
    });

    group('isValidUrl', () {
      test('returns false for null or empty input', () {
        expect(UrlUtils.isValidUrl(null), false);
        expect(UrlUtils.isValidUrl(''), false);
      });

      test('returns true for valid http/https URLs', () {
        expect(UrlUtils.isValidUrl('http://example.com'), true);
        expect(UrlUtils.isValidUrl('https://example.com'), true);
        expect(UrlUtils.isValidUrl('https://example.com/path?query=1'), true);
      });

      test('returns false for invalid URLs', () {
        expect(UrlUtils.isValidUrl('not-a-url'), false);
        expect(UrlUtils.isValidUrl('ftp://example.com'), false);
      });
    });

    group('extractBvid', () {
      test('extracts BV ID from full URL', () {
        expect(
          UrlUtils.extractBvid('https://www.bilibili.com/video/BV1xx411c7mD'),
          'BV1xx411c7mD',
        );
      });

      test('extracts BV ID from URL with query params', () {
        expect(
          UrlUtils.extractBvid('https://www.bilibili.com/video/BV1ab4y1E7DK?from=search'),
          'BV1ab4y1E7DK',
        );
      });

      test('extracts standalone BV ID', () {
        expect(UrlUtils.extractBvid('BV1xx411c7mD'), 'BV1xx411c7mD');
      });

      test('returns null for invalid input', () {
        expect(UrlUtils.extractBvid('https://www.bilibili.com/'), null);
        expect(UrlUtils.extractBvid('av12345'), null);
      });
    });

    group('buildVideoUrl', () {
      test('builds correct video URL', () {
        expect(
          UrlUtils.buildVideoUrl('BV1xx411c7mD'),
          'https://www.bilibili.com/video/BV1xx411c7mD',
        );
      });
    });

    group('buildAudioUrl', () {
      test('builds correct audio URL', () {
        expect(
          UrlUtils.buildAudioUrl(12345),
          'https://www.bilibili.com/audio/au12345',
        );
      });
    });

    group('buildUserUrl', () {
      test('builds correct user space URL', () {
        expect(
          UrlUtils.buildUserUrl(123456),
          'https://space.bilibili.com/123456',
        );
      });
    });
  });
}
