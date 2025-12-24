import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../data/models/following_user.dart';
import '../providers/follow_notifier.dart';
import '../widgets/following_card.dart';

/// Screen displaying user's followings list with grid layout
class FollowListScreen extends ConsumerStatefulWidget {
  const FollowListScreen({super.key});

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load followings on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(followProvider.notifier).load();
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
      ref.read(followProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final followState = ref.watch(followProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(followProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              title: Text(
                'My Followings${followState.totalCount > 0 ? ' (${followState.totalCount})' : ''}',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: followState.isLoading
                      ? null
                      : () => ref.read(followProvider.notifier).refresh(),
                ),
              ],
            ),
            // Content
            _buildContent(context, followState),
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
          message: 'Please login to view your followings',
          onRetry: () => context.go(AppRoutes.login),
          retryText: 'Login',
        ),
      );
    }

    // Privacy state
    if (state.isPrivate) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'Privacy Enabled',
          message: 'User has enabled privacy settings',
        ),
      );
    }

    // Initial loading
    if (state.isLoading && state.users.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingState(message: 'Loading followings...'),
      );
    }

    // Error state
    if (state.hasError && state.users.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'Failed to load',
          message: state.errorMessage,
          onRetry: () => ref.read(followProvider.notifier).load(),
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          title: 'No followings',
          message: 'You have not followed anyone yet',
        ),
      );
    }

    // Followings grid
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at the end
            if (index == state.users.length) {
              return _buildLoadingIndicator(state);
            }

            final user = state.users[index];
            return FollowingCard(
              user: user,
              onTap: () => _navigateToUserSpace(user),
              onUnfollow: () => _confirmUnfollow(context, user),
            );
          },
          childCount: state.users.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(state) {
    if (state.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _navigateToUserSpace(FollowingUser user) {
    // Navigate to user space page
    context.push(AppRoutes.userSpacePath(user.mid));
  }

  void _confirmUnfollow(BuildContext context, FollowingUser user) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfollow?'),
        content: Text(
          'Are you sure you want to unfollow "${user.uname}"?',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Unfollow'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed ?? false) {
        final success =
            await ref.read(followProvider.notifier).unfollowUser(user);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Unfollowed' : 'Failed to unfollow'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }
}
