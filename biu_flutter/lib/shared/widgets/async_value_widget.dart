import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';
import 'loading_state.dart';

/// A wrapper widget that handles AsyncValue states uniformly.
///
/// Displays loading, error, or data content based on the AsyncValue state.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    super.key,
    this.loading,
    this.error,
    this.skipLoadingOnRefresh = true,
    this.skipLoadingOnReload = false,
  });

  /// The AsyncValue to render
  final AsyncValue<T> value;

  /// Builder for the data state
  final Widget Function(T data) data;

  /// Optional custom loading widget
  final Widget? loading;

  /// Optional custom error widget builder
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  /// Skip showing loading indicator when refreshing
  final bool skipLoadingOnRefresh;

  /// Skip showing loading indicator when reloading
  final bool skipLoadingOnReload;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const LoadingState(),
      error: (e, st) =>
          error?.call(e, st) ??
          ErrorState(
            message: e.toString(),
            onRetry: null, // Caller should handle retry
          ),
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
    );
  }
}

/// A Sliver version of AsyncValueWidget for use in CustomScrollView
class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    required this.value,
    required this.data,
    super.key,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SliverFillRemaining(
        hasScrollBody: false,
        child: loading ?? const LoadingState(),
      ),
      error: (e, st) => SliverFillRemaining(
        hasScrollBody: false,
        child: error?.call(e, st) ??
            ErrorState(
              message: e.toString(),
            ),
      ),
    );
  }
}

/// A widget that shows content with an optional loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: Colors.black54,
            child: LoadingState(message: message),
          ),
      ],
    );
  }
}

/// A pull-to-refresh wrapper with consistent styling
class RefreshableContent extends StatelessWidget {
  const RefreshableContent({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
