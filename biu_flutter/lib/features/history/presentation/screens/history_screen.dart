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
import '../widgets/history_item_card.dart';

/// Screen displaying watch history with infinite scroll
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
              title: const Text('History'),
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

  Widget _buildContent(BuildContext context, state) {
    // Not logged in state
    if (state.isNotLoggedIn) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'Login Required',
          message: 'Please login to view your watch history',
          onRetry: () => context.go(AppRoutes.login),
          retryText: 'Login',
        ),
      );
    }

    // Initial loading
    if (state.isLoading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: 'Loading history...'),
      );
    }

    // Error state
    if (state.hasError && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'Failed to load',
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
          title: 'No history',
          message: 'Your watch history will appear here',
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

  Widget _buildLoadingIndicator(state) {
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
            child: const Text('Load more'),
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
          content: Text('Cannot play this type of content'),
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
