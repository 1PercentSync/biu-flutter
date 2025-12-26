import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../providers/dynamic_feed_notifier.dart';
import '../providers/dynamic_feed_state.dart';
import 'dynamic_feed_item.dart';

/// Drawer widget for displaying dynamic feed from followed users.
///
/// Shows a modal bottom sheet with:
/// - Header with title
/// - Scrollable list of dynamic items
/// - Infinite scroll pagination
/// - Pull-to-refresh
///
/// Source: biu/src/components/dynamic-feed/index.tsx
class DynamicFeedDrawer extends ConsumerStatefulWidget {
  const DynamicFeedDrawer({super.key});

  /// Show the drawer as a modal bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DynamicFeedDrawer(),
    );
  }

  @override
  ConsumerState<DynamicFeedDrawer> createState() => _DynamicFeedDrawerState();
}

class _DynamicFeedDrawerState extends ConsumerState<DynamicFeedDrawer> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(dynamicFeedProvider);
      if (!state.isInitialized && !state.isLoading) {
        ref.read(dynamicFeedProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref.read(dynamicFeedProvider.notifier).loadMore();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= maxScroll - 200;
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final state = ref.watch(dynamicFeedProvider);

    // Calculate drawer height (85% of screen)
    final drawerHeight = mediaQuery.size.height * 0.85;

    return Container(
      height: drawerHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          const Divider(height: 1, color: AppColors.divider),

          // Content
          Expanded(
            child: _buildContent(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Handle bar
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DynamicFeedState state) {
    // Initial loading
    if (!state.isInitialized && state.isLoading) {
      return const LoadingState(message: '加载动态中...');
    }

    // Error state
    if (state.hasError && state.items.isEmpty) {
      return ErrorState(
        title: '加载失败',
        message: state.error,
        onRetry: () => ref.read(dynamicFeedProvider.notifier).refresh(),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return const EmptyState(
        icon: Icon(CupertinoIcons.list_bullet, size: 48, color: AppColors.textTertiary),
        title: '暂无动态',
        message: '关注的用户还没有发布动态',
      );
    }

    // Content list
    return RefreshIndicator(
      onRefresh: () => ref.read(dynamicFeedProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == state.items.length) {
            return _buildFooter(state);
          }

          final item = state.items[index];
          return DynamicFeedItem(
            item: item,
            onClose: _closeDrawer,
          );
        },
      ),
    );
  }

  Widget _buildFooter(DynamicFeedState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasMore && state.items.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            '没有更多了',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
