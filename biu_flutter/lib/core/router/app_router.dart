import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/artist_rank/artist_rank.dart';
import '../../features/auth/auth.dart';
import '../../features/collection/presentation/screens/video_series_detail_screen.dart';
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
import '../../shared/widgets/glass/glass.dart';
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
        builder: (context, state) => const PlaybarScaffold(
          child: ArtistRankScreen(),
        ),
      ),
      // Music Recommend route
      GoRoute(
        path: AppRoutes.musicRecommend,
        name: 'musicRecommend',
        builder: (context, state) => const PlaybarScaffold(
          child: MusicRecommendScreen(),
        ),
      ),
      // Follow List route
      GoRoute(
        path: AppRoutes.followList,
        name: 'followList',
        builder: (context, state) => const PlaybarScaffold(
          child: FollowListScreen(),
        ),
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
          return PlaybarScaffold(child: UserProfileScreen(mid: mid));
        },
      ),
      // Watch Later route
      GoRoute(
        path: AppRoutes.later,
        name: 'later',
        builder: (context, state) => const PlaybarScaffold(
          child: LaterScreen(),
        ),
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
          return PlaybarScaffold(child: FolderDetailScreen(folderId: folderId));
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
      // Collection route (video series, favorites, etc.)
      // Source: biu/src/pages/video-collection/index.tsx
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
          // Route to appropriate screen based on collection type
          switch (type) {
            case 'video_series':
              return VideoSeriesDetailScreen(seasonId: id);
            case 'favorite':
              // Favorite collections use the existing folder detail screen
              return FolderDetailScreen(folderId: id);
            default:
              // Fallback for unknown types
              return Scaffold(
                appBar: AppBar(title: const Text('合集')),
                body: Center(
                  child: Text('不支持的合集类型: $type'),
                ),
              );
          }
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

/// Main shell widget with iOS-style floating playbar and glass bottom navigation.
///
/// Uses Stack layout to layer:
/// 1. Main content area (with bottom padding for floating elements)
/// 2. Bottom frosted glass backdrop
/// 3. Floating mini playbar
/// 4. Glass bottom navigation
///
/// Source: prototype/home_tabs_prototype.html (iOS-native design)
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSafeArea = mediaQuery.padding.bottom;

    // Calculate the bottom padding needed for content to avoid floating elements
    final contentBottomPadding = AppTheme.bottomNavHeight +
        bottomSafeArea +
        AppTheme.miniPlayerHeight +
        AppTheme.miniPlayerMargin * 2;

    // Height of the glass backdrop at the bottom (nav + safe area)
    final bottomGlassHeight = AppTheme.bottomNavHeight + bottomSafeArea;

    // Position of mini player from bottom
    final miniPlayerBottom =
        AppTheme.bottomNavHeight + bottomSafeArea + AppTheme.miniPlayerMargin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Main content area with bottom padding
          Positioned.fill(
            child: MediaQuery(
              // Provide adjusted padding to child for proper scroll behavior
              data: mediaQuery.copyWith(
                padding: mediaQuery.padding.copyWith(
                  bottom: contentBottomPadding,
                ),
              ),
              child: child,
            ),
          ),

          // 2. Bottom frosted glass backdrop
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomGlassHeight,
            child: const GlassBackdrop(
              alignment: Alignment.bottomCenter,
            ),
          ),

          // 3. Floating mini playbar
          Positioned(
            left: AppTheme.miniPlayerMargin,
            right: AppTheme.miniPlayerMargin,
            bottom: miniPlayerBottom,
            child: MiniPlaybar(
              onTap: () => context.push('/player'),
            ),
          ),

          // 4. Glass bottom navigation (on top of backdrop)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNav(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (index) => _onItemTapped(index, context),
            ),
          ),
        ],
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

/// Scaffold wrapper that includes floating MiniPlaybar for non-shell routes.
///
/// Provides iOS-style floating playbar at the bottom of screens that are
/// outside the main shell (e.g., artist rank, music recommend).
class PlaybarScaffold extends ConsumerWidget {
  const PlaybarScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSafeArea = mediaQuery.padding.bottom;

    // Calculate bottom padding for content
    final contentBottomPadding =
        AppTheme.miniPlayerHeight + AppTheme.miniPlayerMargin * 2 + bottomSafeArea;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content with bottom padding
          Positioned.fill(
            child: MediaQuery(
              data: mediaQuery.copyWith(
                padding: mediaQuery.padding.copyWith(
                  bottom: contentBottomPadding,
                ),
              ),
              child: child,
            ),
          ),

          // Floating mini playbar
          Positioned(
            left: AppTheme.miniPlayerMargin,
            right: AppTheme.miniPlayerMargin,
            bottom: bottomSafeArea + AppTheme.miniPlayerMargin,
            child: MiniPlaybar(
              onTap: () => context.push('/player'),
            ),
          ),
        ],
      ),
    );
  }
}
