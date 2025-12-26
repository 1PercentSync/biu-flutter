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
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/models/watch_later_item.dart';
import '../providers/later_notifier.dart';
import '../providers/later_state.dart';
import '../widgets/later_item_card.dart';
import '../widgets/later_item_list_tile.dart';

const _uuid = Uuid();

/// Screen displaying watch later list with infinite scroll
///
/// Source: biu/src/pages/later/index.tsx#Later
class LaterScreen extends ConsumerStatefulWidget {
  const LaterScreen({super.key});

  @override
  ConsumerState<LaterScreen> createState() => _LaterScreenState();
}

class _LaterScreenState extends ConsumerState<LaterScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load watch later on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(laterProvider.notifier).load();
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
      ref.read(laterProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final laterState = ref.watch(laterProvider);
    final displayMode = ref.watch(displayModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(laterProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            const SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: Text('稍后再看'),
            ),
            // Content
            _buildContent(context, laterState, displayMode),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LaterState state,
    DisplayMode displayMode,
  ) {
    // Not logged in state
    if (state.isNotLoggedIn) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '需要登录',
          message: '请登录查看稍后再看列表',
          onRetry: () => context.go(AppRoutes.login),
          retryText: '登录',
        ),
      );
    }

    // Initial loading
    if (state.isLoading && state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: '加载稍后再看...'),
      );
    }

    // Error state
    if (state.hasError && state.items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '加载失败',
          message: state.errorMessage,
          onRetry: () => ref.read(laterProvider.notifier).load(),
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: '暂无视频',
          message: '你添加到稍后再看的视频将显示在这里',
        ),
      );
    }

    // Watch later list - card mode or list mode
    // Source: biu/src/pages/later/index.tsx:139-143
    if (displayMode == DisplayMode.card) {
      return _buildCardGrid(context, state);
    } else {
      return _buildListView(context, state);
    }
  }

  /// Build card grid layout (displayMode === "card")
  /// Source: biu/src/pages/later/index.tsx:139-140 - uses GridList
  Widget _buildCardGrid(BuildContext context, LaterState state) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at the end
            if (index == state.items.length) {
              return _buildLoadingIndicator(state);
            }

            final item = state.items[index];
            return LaterItemCard(
              item: item,
              onTap: () => _playItem(item),
              onDelete: () => _confirmDelete(context, item),
            );
          },
          childCount: state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  /// Build list layout (displayMode === "list")
  /// Source: biu/src/pages/later/index.tsx:141-143 - uses plain div list
  Widget _buildListView(BuildContext context, LaterState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at the end
            if (index == state.items.length) {
              return _buildLoadingIndicator(state);
            }

            final item = state.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: LaterItemListTile(
                item: item,
                onTap: () => _playItem(item),
                onDelete: () => _confirmDelete(context, item),
              ),
            );
          },
          childCount: state.items.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(LaterState state) {
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
            onPressed: () => ref.read(laterProvider.notifier).loadMore(),
            child: const Text('加载更多'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _playItem(WatchLaterItem item) {
    if (!item.isPlayable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法播放此视频'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Don't pass ownerMid to trigger fetching all pages
    // Source: biu/src/store/play-list.ts:527-535
    final playItem = PlayItem(
      id: _uuid.v4(),
      title: item.title,
      type: PlayDataType.mv,
      bvid: item.bvid,
      aid: item.aid.toString(),
      cid: item.cid.toString(),
      cover: item.pic,
      ownerName: item.owner?.name,
      // ownerMid intentionally omitted to trigger multi-part fetch
      duration: item.duration,
    );

    ref.read(playlistProvider.notifier).play(playItem);
  }

  void _confirmDelete(BuildContext context, WatchLaterItem item) {
    // Source: biu/src/pages/later/index.tsx:61-83 - uses onOpenConfirmModal
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed ?? false) {
        final success =
            await ref.read(laterProvider.notifier).removeItem(item);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '删除成功' : '删除失败'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }
}
