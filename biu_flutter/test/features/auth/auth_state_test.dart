import 'package:flutter_test/flutter_test.dart';
import 'package:biu_flutter/features/auth/presentation/providers/auth_state.dart';
import 'package:biu_flutter/features/auth/domain/entities/user.dart';
import 'package:biu_flutter/features/auth/domain/entities/auth_token.dart';

void main() {
  group('AuthStatus', () {
    test('has all expected values', () {
      expect(AuthStatus.values, containsAll([
        AuthStatus.initial,
        AuthStatus.unauthenticated,
        AuthStatus.authenticating,
        AuthStatus.authenticated,
        AuthStatus.error,
      ]));
    });
  });

  group('AuthState', () {
    test('initial state has correct defaults', () {
      const state = AuthState.initial;
      expect(state.status, AuthStatus.initial);
      expect(state.user, null);
      expect(state.token, null);
      expect(state.errorMessage, null);
      expect(state.isRefreshing, false);
    });

    test('isAuthenticated returns true when authenticated with user', () {
      final user = _createTestUser();
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      expect(state.isAuthenticated, true);
    });

    test('isAuthenticated returns false when authenticated without user', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isAuthenticated, false);
    });

    test('isAuthenticated returns false when not authenticated', () {
      final state = AuthState(
        status: AuthStatus.unauthenticated,
        user: _createTestUser(),
      );
      expect(state.isAuthenticated, false);
    });

    test('isLoading returns true for initial status', () {
      const state = AuthState(status: AuthStatus.initial);
      expect(state.isLoading, true);
    });

    test('isLoading returns false for other statuses', () {
      expect(
        const AuthState(status: AuthStatus.authenticated).isLoading,
        false,
      );
      expect(
        const AuthState(status: AuthStatus.unauthenticated).isLoading,
        false,
      );
      expect(
        const AuthState(status: AuthStatus.error).isLoading,
        false,
      );
    });

    group('copyWith', () {
      test('updates status', () {
        const initial = AuthState.initial;
        final updated = initial.copyWith(status: AuthStatus.authenticated);
        expect(updated.status, AuthStatus.authenticated);
      });

      test('updates user', () {
        const initial = AuthState.initial;
        final user = _createTestUser();
        final updated = initial.copyWith(user: user);
        expect(updated.user, user);
      });

      test('clears user when clearUser is true', () {
        final state = AuthState(user: _createTestUser());
        final cleared = state.copyWith(clearUser: true);
        expect(cleared.user, null);
      });

      test('clears error when clearError is true', () {
        const state = AuthState(errorMessage: 'Test error');
        final cleared = state.copyWith(clearError: true);
        expect(cleared.errorMessage, null);
      });

      test('preserves other fields when updating one', () {
        final user = _createTestUser();
        final state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: 'some error',
        );

        final updated = state.copyWith(isRefreshing: true);

        expect(updated.status, AuthStatus.authenticated);
        expect(updated.user, user);
        expect(updated.errorMessage, 'some error');
        expect(updated.isRefreshing, true);
      });
    });

    test('toString contains relevant info', () {
      final user = _createTestUser();
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      final str = state.toString();
      expect(str, contains('authenticated'));
      expect(str, contains(user.uname));
    });
  });

  group('User', () {
    test('creates user with required fields', () {
      final user = _createTestUser();
      expect(user.mid, 12345);
      expect(user.uname, 'TestUser');
      expect(user.face, 'https://example.com/avatar.jpg');
      expect(user.isLogin, true);
    });

    test('isVip returns true when vipStatus is 1', () {
      final user = _createTestUser(vipStatus: 1);
      expect(user.isVip, true);
    });

    test('isVip returns false when vipStatus is 0', () {
      final user = _createTestUser(vipStatus: 0);
      expect(user.isVip, false);
    });

    test('isAnnualVip returns true when vipType >= 2', () {
      expect(_createTestUser(vipType: 2).isAnnualVip, true);
      expect(_createTestUser(vipType: 3).isAnnualVip, true);
    });

    test('isAnnualVip returns false when vipType < 2', () {
      expect(_createTestUser(vipType: 0).isAnnualVip, false);
      expect(_createTestUser(vipType: 1).isAnnualVip, false);
    });

    test('copyWith updates fields correctly', () {
      final user = _createTestUser();
      final updated = user.copyWith(uname: 'NewName', level: 6);

      expect(updated.uname, 'NewName');
      expect(updated.level, 6);
      expect(updated.mid, user.mid); // Unchanged
    });

    test('equality based on mid', () {
      final user1 = _createTestUser(mid: 123);
      final user2 = _createTestUser(mid: 123, uname: 'DifferentName');
      final user3 = _createTestUser(mid: 456);

      expect(user1 == user2, true);
      expect(user1 == user3, false);
    });

    test('hashCode based on mid', () {
      final user1 = _createTestUser(mid: 123);
      final user2 = _createTestUser(mid: 123);

      expect(user1.hashCode, user2.hashCode);
    });
  });
}

User _createTestUser({
  int mid = 12345,
  String uname = 'TestUser',
  int vipStatus = 0,
  int vipType = 0,
}) {
  return User(
    mid: mid,
    uname: uname,
    face: 'https://example.com/avatar.jpg',
    isLogin: true,
    vipStatus: vipStatus,
    vipType: vipType,
  );
}
