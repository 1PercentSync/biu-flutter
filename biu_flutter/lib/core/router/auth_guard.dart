import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth.dart';
import 'routes.dart';

/// Provider for the auth guard
final authGuardProvider = Provider<AuthGuard>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return AuthGuard(authState: authState);
});

/// Guard for protecting routes that require authentication
class AuthGuard {
  AuthGuard({required this.authState});

  final AuthState authState;

  /// Check if user is authenticated
  bool get isAuthenticated => authState.isAuthenticated;

  /// Check if auth state is still loading
  bool get isLoading => authState.isLoading;

  /// Redirect logic for the router
  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.uri.path == AppRoutes.login;
    final isGoingToProtectedRoute = isProtectedRoute(state.uri.path);

    // Don't redirect while still checking auth status
    if (isLoading) {
      return null;
    }

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
