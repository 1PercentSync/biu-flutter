import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../player/player.dart';
import '../../data/models/history_item.dart';
import '../providers/history_notifier.dart';
import '../providers/history_state.dart';
import '../widgets/history_item_card.dart';

/// Screen displaying watch history with infinite scroll
///
/// Source: biu/src/pages/history/index.tsx#History
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _uuid = Uuid();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load history on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).load();
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near the bottom, load more
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(historyProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: const Text('历史记录'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: historyState.isLoading
                      ? null
                      : () => ref.read(historyProvider.notifier).refresh(),
                ),
              ],
            ),
            // Content
            _buildContent(context, historyState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoryState state) {
    // Not logged in state
    if (state.isNotLoggedIn) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '需要登录',
          message: '请登录查看观看历史',
          onRetry: () => context.go(AppRoutes.login),
          retryText: '登录',
        ),
      );
    }

    // Initial loading
    if (state.isLoading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: '加载历史记录中...'),
      );
    }

    // Error state
    if (state.hasError && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '加载失败',
          message: state.errorMessage,
          onRetry: () => ref.read(historyProvider.notifier).load(),
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '暂无历史记录',
          message: '你的观看历史将显示在这里',
        ),
      );
    }

    // History list
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at the end
            if (index == state.items.length) {
              return _buildLoadingIndicator(state);
            }

            final item = state.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HistoryItemCard(
                item: item,
                onTap: () => _playItem(item),
              ),
            );
          },
          childCount: state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(HistoryState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Show "Load More" button if not auto-loading
    if (state.hasMore && !state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton(
            onPressed: () => ref.read(historyProvider.notifier).loadMore(),
            child: const Text('加载更多'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _playItem(HistoryItem item) {
    if (!item.isPlayable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法播放此类型内容'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final playItem = PlayItem(
      id: _uuid.v4(),
      title: item.title,
      type: PlayDataType.mv,
      bvid: item.history.bvid,
      aid: item.history.oid.toString(),
      cid: item.history.cid?.toString(),
      cover: item.cover,
      ownerName: item.authorName,
      ownerMid: item.authorMid,
      duration: item.duration,
    );

    ref.read(playlistProvider.notifier).play(playItem);
  }
}
