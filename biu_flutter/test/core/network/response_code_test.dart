import 'package:biu_flutter/core/constants/response_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiliErrorCode', () {
    group('fromCode', () {
      test('returns correct error code for known codes', () {
        expect(BiliErrorCode.fromCode(-101), BiliErrorCode.notLoggedIn);
        expect(BiliErrorCode.fromCode(-102), BiliErrorCode.accountBanned);
        expect(BiliErrorCode.fromCode(-400), BiliErrorCode.badRequest);
        expect(BiliErrorCode.fromCode(-404), BiliErrorCode.notFound);
        expect(BiliErrorCode.fromCode(-500), BiliErrorCode.internalServerError);
      });

      test('returns null for unknown codes', () {
        expect(BiliErrorCode.fromCode(0), null);
        expect(BiliErrorCode.fromCode(12345), null);
        expect(BiliErrorCode.fromCode(-99999), null);
      });
    });

    group('isAuthRequired', () {
      test('returns true for authentication-required codes', () {
        expect(BiliErrorCode.isAuthRequired(-101), true); // notLoggedIn
        expect(BiliErrorCode.isAuthRequired(-102), true); // accountBanned
        expect(BiliErrorCode.isAuthRequired(-658), true); // tokenExpired
      });

      test('returns false for other codes', () {
        expect(BiliErrorCode.isAuthRequired(-400), false);
        expect(BiliErrorCode.isAuthRequired(-403), false);
        expect(BiliErrorCode.isAuthRequired(-404), false);
        expect(BiliErrorCode.isAuthRequired(-500), false);
        expect(BiliErrorCode.isAuthRequired(0), false);
      });
    });

    group('error codes values', () {
      test('has correct code for common errors', () {
        expect(BiliErrorCode.notLoggedIn.code, -101);
        expect(BiliErrorCode.accountBanned.code, -102);
        expect(BiliErrorCode.badRequest.code, -400);
        expect(BiliErrorCode.unauthorizedOrIllegalRequest.code, -401);
        expect(BiliErrorCode.forbidden.code, -403);
        expect(BiliErrorCode.notFound.code, -404);
        expect(BiliErrorCode.internalServerError.code, -500);
      });

      test('has meaningful messages', () {
        expect(BiliErrorCode.notLoggedIn.message, isNotEmpty);
        expect(BiliErrorCode.badRequest.message, isNotEmpty);
        expect(BiliErrorCode.notFound.message, isNotEmpty);
      });
    });

    group('all error codes are unique', () {
      test('no duplicate codes', () {
        final codes = BiliErrorCode.values.map((e) => e.code).toList();
        final uniqueCodes = codes.toSet();
        expect(codes.length, uniqueCodes.length);
      });
    });
  });
}
