import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// Provider for authentication state
/// This is a placeholder - will be implemented in the auth feature
final authStateProvider = StateProvider<bool>((ref) => false);

/// Provider for the auth guard
final authGuardProvider = Provider<AuthGuard>((ref) {
  final isAuthenticated = ref.watch(authStateProvider);
  return AuthGuard(isAuthenticated: isAuthenticated);
});

/// Guard for protecting routes that require authentication
class AuthGuard {
  AuthGuard({required this.isAuthenticated});

  final bool isAuthenticated;

  /// Redirect logic for the router
  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.uri.path == AppRoutes.login;
    final isGoingToProtectedRoute = isProtectedRoute(state.uri.path);

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated && isGoingToProtectedRoute) {
      // Store the intended destination for after login
      return '${AppRoutes.login}?redirect=${state.uri.path}';
    }

    // If authenticated and on login page, redirect to home or intended destination
    if (isAuthenticated && isLoggingIn) {
      final redirect = state.uri.queryParameters['redirect'];
      return redirect ?? AppRoutes.home;
    }

    // No redirect needed
    return null;
  }
}
