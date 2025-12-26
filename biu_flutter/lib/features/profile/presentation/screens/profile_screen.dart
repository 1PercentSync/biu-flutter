import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../dynamic_feed/dynamic_feed.dart';

/// Profile screen showing user information and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: const Text('我的'),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.gear_alt_fill),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: _buildContent(context, ref, authState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // User info card
          _buildUserCard(context, ref, authState),
          const SizedBox(height: 24),
          // Menu items
          _buildMenuSection(context, authState.isAuthenticated),
          // Logout button (only when logged in)
          if (authState.isAuthenticated) ...[
            const SizedBox(height: 24),
            _buildLogoutButton(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, AuthState authState) {
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          // Avatar
          UserAvatar(
            avatarUrl: isLoggedIn ? user?.face : null,
            size: 64,
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? (user?.uname ?? '用户') : '未登录',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn
                      ? 'UID: ${user?.mid ?? ''}'
                      : '登录以使用全部功能',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Login/Navigate button
          if (!isLoggedIn)
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('登录'),
            )
          else if (user?.mid != null)
            IconButton(
              icon: const Icon(CupertinoIcons.chevron_right),
              onPressed: () => context.push(AppRoutes.userSpacePath(user!.mid)),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isLoggedIn) {
    return Column(
      children: [
        if (isLoggedIn) ...[
          _buildMenuItem(
            context,
            icon: CupertinoIcons.list_bullet,
            title: '动态',
            onTap: () => DynamicFeedDrawer.show(context),
          ),
          _buildMenuItem(
            context,
            icon: CupertinoIcons.person_2,
            title: '我的关注',
            onTap: () => context.push(AppRoutes.followList),
          ),
          _buildMenuItem(
            context,
            icon: CupertinoIcons.clock_fill,
            title: '稍后再看',
            onTap: () => context.push(AppRoutes.later),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        leading: const Icon(CupertinoIcons.square_arrow_right, color: AppColors.error),
        title: const Text(
          '退出登录',
          style: TextStyle(color: AppColors.error),
        ),
        onTap: () => _showLogoutDialog(context, ref),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.contentBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title),
        trailing: trailing ?? const Icon(CupertinoIcons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }
}
