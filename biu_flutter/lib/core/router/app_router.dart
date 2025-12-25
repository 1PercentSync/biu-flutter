import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/artist_rank/artist_rank.dart';
import '../../features/auth/auth.dart';
import '../../features/favorites/favorites.dart';
import '../../features/follow/follow.dart';
import '../../features/history/history.dart';
import '../../features/home/home.dart';
import '../../features/later/later.dart';
import '../../features/music_recommend/music_recommend.dart';
import '../../features/profile/profile.dart';
import '../../features/search/search.dart';
import '../../features/settings/settings.dart';
import '../../features/user_profile/user_profile.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/playbar/playbar.dart';
import 'auth_guard.dart';
import 'routes.dart';

/// Provider for the app router.
///
/// Implements app navigation using GoRouter with route guards.
///
/// Source: biu/src/routes.tsx + biu/src/app.tsx (route definitions)
/// Note: Flutter uses declarative routing (GoRouter) vs React Router.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = ref.watch(authGuardProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: authGuard.redirect,
    routes: [
      // Main shell with bottom navigation and playbar
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            name: 'favorites',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
      // Login route (outside shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Settings route (outside shell)
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // About route
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      // Artist Rank route
      GoRoute(
        path: AppRoutes.artistRank,
        name: 'artistRank',
        builder: (context, state) => const ArtistRankScreen(),
      ),
      // Music Recommend route
      GoRoute(
        path: AppRoutes.musicRecommend,
        name: 'musicRecommend',
        builder: (context, state) => const MusicRecommendScreen(),
      ),
      // Follow List route
      GoRoute(
        path: AppRoutes.followList,
        name: 'followList',
        builder: (context, state) => const FollowListScreen(),
      ),
      // User Space/Profile route
      GoRoute(
        path: AppRoutes.userSpace,
        name: 'userSpace',
        builder: (context, state) {
          final mid = int.tryParse(state.pathParameters['mid'] ?? '');
          if (mid == null) {
            return const Scaffold(
              body: Center(child: Text('无效的用户ID')),
            );
          }
          return UserProfileScreen(mid: mid);
        },
      ),
      // Watch Later route
      GoRoute(
        path: AppRoutes.later,
        name: 'later',
        builder: (context, state) => const LaterScreen(),
      ),
      // Favorites folder detail route
      GoRoute(
        path: AppRoutes.favoritesFolder,
        name: 'favoritesFolder',
        builder: (context, state) {
          final folderId = int.tryParse(state.pathParameters['folderId'] ?? '');
          if (folderId == null) {
            return const Scaffold(
              body: Center(child: Text('无效的收藏夹ID')),
            );
          }
          return FolderDetailScreen(folderId: folderId);
        },
      ),
      // Full player route (modal)
      GoRoute(
        path: '/player',
        name: 'player',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FullPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        ),
      ),
      // Collection route (video series, etc.)
      GoRoute(
        path: AppRoutes.collection,
        name: 'collection',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          final type = state.uri.queryParameters['type'] ?? '';
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('无效的合集ID')),
            );
          }
          // TODO: Implement CollectionScreen for video_series and other types
          return Scaffold(
            appBar: AppBar(
              title: Text(type == 'video_series' ? '视频合集' : '合集'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.construction, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('合集功能开发中', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('ID: $id, 类型: $type', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.uri}'),
      ),
    ),
  );
});

/// Main shell widget with bottom navigation and playbar
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(child: child),
          // Mini playbar
          MiniPlaybar(
            onTap: () => context.push('/player'),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(context),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '历史',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.home) && location == AppRoutes.home) {
      return 0;
    }
    if (location.startsWith(AppRoutes.search)) return 1;
    if (location.startsWith(AppRoutes.favorites)) return 2;
    if (location.startsWith(AppRoutes.history)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.search);
      case 2:
        context.go(AppRoutes.favorites);
      case 3:
        context.go(AppRoutes.history);
      case 4:
        context.go(AppRoutes.profile);
    }
  }
}
