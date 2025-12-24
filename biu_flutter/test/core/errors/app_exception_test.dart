import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/core/errors/app_exception.dart';
import 'package:biu_flutter/core/constants/response_code.dart';

void main() {
  group('AppException', () {
    test('creates exception with message and code', () {
      const exception = AppException(message: 'Test error', code: 100);
      expect(exception.message, 'Test error');
      expect(exception.code, 100);
    });

    test('toString returns formatted message', () {
      const exception = AppException(message: 'Test error', code: 100);
      expect(exception.toString(), 'AppException: Test error (code: 100)');
    });

    test('allows null code', () {
      const exception = AppException(message: 'Test error');
      expect(exception.code, null);
    });
  });

  group('NetworkException', () {
    test('creates exception with all properties', () {
      const exception = NetworkException(
        message: 'Connection failed',
        statusCode: 500,
        url: 'https://example.com/api',
      );
      expect(exception.message, 'Connection failed');
      expect(exception.statusCode, 500);
      expect(exception.url, 'https://example.com/api');
    });

    test('toString returns formatted message with status code', () {
      const exception = NetworkException(
        message: 'Connection failed',
        statusCode: 500,
      );
      expect(
        exception.toString(),
        'NetworkException: Connection failed (statusCode: 500)',
      );
    });
  });

  group('BilibiliApiException', () {
    test('creates exception from known error code', () {
      final exception = BilibiliApiException(code: -101);
      expect(exception.code, -101);
      expect(exception.message, 'Not logged in');
      expect(exception.errorCode, BiliErrorCode.notLoggedIn);
    });

    test('creates exception with custom message', () {
      final exception = BilibiliApiException(
        code: -101,
        message: 'Custom message',
      );
      expect(exception.message, 'Custom message');
    });

    test('creates exception from unknown error code', () {
      final exception = BilibiliApiException(code: -99999);
      expect(exception.message, 'Unknown error');
      expect(exception.errorCode, null);
    });

    test('isAuthRequired returns true for auth-required codes', () {
      final notLoggedIn = BilibiliApiException(code: -101);
      expect(notLoggedIn.isAuthRequired, true);

      final accountBanned = BilibiliApiException(code: -102);
      expect(accountBanned.isAuthRequired, true);

      final tokenExpired = BilibiliApiException(code: -658);
      expect(tokenExpired.isAuthRequired, true);
    });

    test('isAuthRequired returns false for other codes', () {
      final badRequest = BilibiliApiException(code: -400);
      expect(badRequest.isAuthRequired, false);

      final notFound = BilibiliApiException(code: -404);
      expect(notFound.isAuthRequired, false);
    });

    test('stores request URL', () {
      final exception = BilibiliApiException(
        code: -404,
        requestUrl: 'https://api.bilibili.com/test',
      );
      expect(exception.requestUrl, 'https://api.bilibili.com/test');
    });
  });

  group('AuthException', () {
    test('creates exception with requiresRelogin flag', () {
      const exception = AuthException(
        message: 'Session expired',
        requiresRelogin: true,
      );
      expect(exception.message, 'Session expired');
      expect(exception.requiresRelogin, true);
    });

    test('defaults requiresRelogin to false', () {
      const exception = AuthException(message: 'Auth error');
      expect(exception.requiresRelogin, false);
    });
  });

  group('StorageException', () {
    test('creates exception with storage key', () {
      const exception = StorageException(
        message: 'Failed to read value',
        key: 'user_token',
      );
      expect(exception.message, 'Failed to read value');
      expect(exception.key, 'user_token');
    });

    test('toString includes key', () {
      const exception = StorageException(
        message: 'Failed to read value',
        key: 'user_token',
      );
      expect(
        exception.toString(),
        'StorageException: Failed to read value (key: user_token)',
      );
    });
  });

  group('PlayerException', () {
    test('creates exception with source', () {
      const exception = PlayerException(
        message: 'Failed to load audio',
        source: 'https://example.com/audio.mp3',
      );
      expect(exception.message, 'Failed to load audio');
      expect(exception.source, 'https://example.com/audio.mp3');
    });
  });
}
