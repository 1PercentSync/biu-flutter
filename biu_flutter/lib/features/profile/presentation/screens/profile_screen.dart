import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

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
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
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
          _buildMenuSection(context),
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
          ClipOval(
            child: isLoggedIn && user?.face != null
                ? AppCachedImage(
                    imageUrl: user!.face,
                    width: 64,
                    height: 64,
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? (user?.uname ?? 'User') : 'Not Logged In',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn
                      ? 'UID: ${user?.mid ?? ''}'
                      : 'Login to access all features',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Login/Logout button
          if (!isLoggedIn)
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Login'),
            )
          else
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Navigate to user detail
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.people_outline,
          title: 'My Followings',
          onTap: () => context.push(AppRoutes.followList),
        ),
        _buildMenuItem(
          context,
          icon: Icons.history,
          title: 'Watch History',
          onTap: () => context.push(AppRoutes.history),
        ),
        _buildMenuItem(
          context,
          icon: Icons.watch_later_outlined,
          title: 'Watch Later',
          onTap: () => context.push(AppRoutes.later),
        ),
        _buildMenuItem(
          context,
          icon: Icons.dark_mode,
          title: 'Theme',
          trailing: const Text(
            'Dark',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () => context.push(AppRoutes.settings),
        ),
        _buildMenuItem(
          context,
          icon: Icons.info_outline,
          title: 'About',
          onTap: () => context.push(AppRoutes.about),
        ),
      ],
    );
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
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }
}
