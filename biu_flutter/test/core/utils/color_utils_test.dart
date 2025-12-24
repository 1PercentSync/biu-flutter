import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/utils/color_utils.dart';

void main() {
  group('ColorUtils', () {
    group('fromHex', () {
      test('returns null for null or empty input', () {
        expect(ColorUtils.fromHex(null), null);
        expect(ColorUtils.fromHex(''), null);
      });

      test('parses #RRGGBB format', () {
        expect(ColorUtils.fromHex('#FF0000'), const Color(0xFFFF0000));
        expect(ColorUtils.fromHex('#00FF00'), const Color(0xFF00FF00));
        expect(ColorUtils.fromHex('#0000FF'), const Color(0xFF0000FF));
        expect(ColorUtils.fromHex('#FFFFFF'), const Color(0xFFFFFFFF));
      });

      test('parses RRGGBB format without #', () {
        expect(ColorUtils.fromHex('FF0000'), const Color(0xFFFF0000));
      });

      test('parses #RGB short format', () {
        expect(ColorUtils.fromHex('#F00'), const Color(0xFFFF0000));
        expect(ColorUtils.fromHex('#0F0'), const Color(0xFF00FF00));
        expect(ColorUtils.fromHex('#00F'), const Color(0xFF0000FF));
      });

      test('parses #AARRGGBB format', () {
        expect(ColorUtils.fromHex('#80FF0000'), const Color(0x80FF0000));
        expect(ColorUtils.fromHex('#00FFFFFF'), const Color(0x00FFFFFF));
      });

      test('returns null for invalid hex', () {
        expect(ColorUtils.fromHex('not-a-color'), null);
        expect(ColorUtils.fromHex('#GGGGGG'), null);
      });
    });

    group('toHex', () {
      test('converts color to hex without alpha', () {
        expect(ColorUtils.toHex(const Color(0xFFFF0000)), '#FF0000');
        expect(ColorUtils.toHex(const Color(0xFF00FF00)), '#00FF00');
        expect(ColorUtils.toHex(const Color(0xFF0000FF)), '#0000FF');
      });

      test('converts color to hex with alpha', () {
        expect(
          ColorUtils.toHex(const Color(0x80FF0000), includeAlpha: true),
          '#80FF0000',
        );
      });
    });

    group('darken', () {
      test('darkens color by specified amount', () {
        final red = const Color(0xFFFF0000);
        final darkened = ColorUtils.darken(red, 0.2);

        // Darkened color should have lower lightness
        final originalHsl = HSLColor.fromColor(red);
        final darkenedHsl = HSLColor.fromColor(darkened);
        expect(darkenedHsl.lightness, lessThan(originalHsl.lightness));
      });

      test('clamps lightness to 0', () {
        final color = const Color(0xFF202020); // Already dark
        final darkened = ColorUtils.darken(color, 1.0);
        final hsl = HSLColor.fromColor(darkened);
        expect(hsl.lightness, 0.0);
      });
    });

    group('lighten', () {
      test('lightens color by specified amount', () {
        final blue = const Color(0xFF0000FF);
        final lightened = ColorUtils.lighten(blue, 0.2);

        // Lightened color should have higher lightness
        final originalHsl = HSLColor.fromColor(blue);
        final lightenedHsl = HSLColor.fromColor(lightened);
        expect(lightenedHsl.lightness, greaterThan(originalHsl.lightness));
      });

      test('clamps lightness to 1', () {
        final color = const Color(0xFFF0F0F0); // Already light
        final lightened = ColorUtils.lighten(color, 1.0);
        final hsl = HSLColor.fromColor(lightened);
        expect(hsl.lightness, 1.0);
      });
    });

    group('getContrastingTextColor', () {
      test('returns black for light backgrounds', () {
        expect(
          ColorUtils.getContrastingTextColor(Colors.white),
          Colors.black,
        );
        expect(
          ColorUtils.getContrastingTextColor(const Color(0xFFF0F0F0)),
          Colors.black,
        );
      });

      test('returns white for dark backgrounds', () {
        expect(
          ColorUtils.getContrastingTextColor(Colors.black),
          Colors.white,
        );
        expect(
          ColorUtils.getContrastingTextColor(const Color(0xFF202020)),
          Colors.white,
        );
      });
    });

    group('withOpacity', () {
      test('creates color with modified opacity', () {
        final color = const Color(0xFFFF0000);
        final transparent = ColorUtils.withOpacity(color, 0.5);
        expect(transparent.a, closeTo(0.5, 0.01));
      });
    });
  });
}
