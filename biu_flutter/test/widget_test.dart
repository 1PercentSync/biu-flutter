// Basic Flutter widget test for BiuApp.
//
// Note: Full integration tests require platform plugins (path_provider, etc.)
// which are not available in the standard test environment.
// These tests focus on unit testing individual components.

import 'package:biu_flutter/features/auth/domain/entities/auth_token.dart';
import 'package:biu_flutter/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User entity tests', () {
    test('User creation', () {
      const user = User(
        mid: 12345,
        uname: 'TestUser',
        face: 'https://example.com/avatar.jpg',
        isLogin: true,
        level: 5,
        vipStatus: 1,
        vipType: 2,
      );

      expect(user.mid, 12345);
      expect(user.uname, 'TestUser');
      expect(user.isLogin, true);
      expect(user.isVip, true);
      expect(user.isAnnualVip, true);
    });

    test('User equality', () {
      const user1 = User(mid: 12345, uname: 'User1', face: '', isLogin: true);
      const user2 = User(mid: 12345, uname: 'User2', face: '', isLogin: false);
      const user3 = User(mid: 67890, uname: 'User1', face: '', isLogin: true);

      // Same mid means equal
      expect(user1 == user2, true);
      // Different mid means not equal
      expect(user1 == user3, false);
    });

    test('User copyWith', () {
      const user = User(mid: 12345, uname: 'Old', face: '', isLogin: true);
      final updated = user.copyWith(uname: 'New');

      expect(updated.mid, 12345);
      expect(updated.uname, 'New');
      expect(user.uname, 'Old'); // Original unchanged
    });
  });

  group('AuthToken entity tests', () {
    test('AuthToken creation', () {
      const token = AuthToken(
        refreshToken: 'test_token',
        nextCheckRefreshTime: 1234567890,
      );

      expect(token.hasToken, true);
      expect(token.refreshToken, 'test_token');
    });

    test('AuthToken empty', () {
      const token = AuthToken.empty;

      expect(token.hasToken, false);
      expect(token.refreshToken, null);
    });

    test('AuthToken shouldCheckRefresh', () {
      // Token with past check time
      final pastTime =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 1000;
      final pastToken = AuthToken(nextCheckRefreshTime: pastTime);
      expect(pastToken.shouldCheckRefresh, true);

      // Token with future check time
      final futureTime =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 100000;
      final futureToken = AuthToken(nextCheckRefreshTime: futureTime);
      expect(futureToken.shouldCheckRefresh, false);
    });

    test('AuthToken JSON serialization', () {
      const token = AuthToken(
        refreshToken: 'test_token',
        nextCheckRefreshTime: 1234567890,
      );

      final json = token.toJson();
      final restored = AuthToken.fromJson(json);

      expect(restored.refreshToken, token.refreshToken);
      expect(restored.nextCheckRefreshTime, token.nextCheckRefreshTime);
    });
  });
}
