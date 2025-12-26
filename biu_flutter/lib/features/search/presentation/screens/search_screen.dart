import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/highlighted_text.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/media_action_menu.dart';
import '../../../player/domain/entities/play_item.dart';
import '../../../player/presentation/providers/playlist_notifier.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/models/search_result.dart';
import '../providers/search_history_notifier.dart';
import '../providers/search_suggestions_notifier.dart';
import '../widgets/search_history_widget.dart';
import '../widgets/search_suggestions_list.dart';
import '../widgets/user_search_card.dart';

/// Provider for search data source
final searchDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource();
});

/// Search tab type
enum SearchTabType { video, user }

/// Search state
class SearchState {
  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.hasSearched = false,
    this.results = const [],
    this.userResults = const [],
    this.error,
    this.musicOnly = true,
    this.searchTab = SearchTabType.video,
    this.currentPage = 1,
    this.totalPages = 0,
    this.isLoadingMore = false,
  });

  final String query;
  final bool isSearching;
  final bool hasSearched;
  final List<SearchVideoItem> results;
  final List<SearchUserItem> userResults;
  final String? error;
  final bool musicOnly;
  final SearchTabType searchTab;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => currentPage < totalPages;

  SearchState copyWith({
    String? query,
    bool? isSearching,
    bool? hasSearched,
    List<SearchVideoItem>? results,
    List<SearchUserItem>? userResults,
    String? error,
    bool clearError = false,
    bool? musicOnly,
    SearchTabType? searchTab,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      hasSearched: hasSearched ?? this.hasSearched,
      results: results ?? this.results,
      userResults: userResults ?? this.userResults,
      error: clearError ? null : (error ?? this.error),
      musicOnly: musicOnly ?? this.musicOnly,
      searchTab: searchTab ?? this.searchTab,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Search state notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._dataSource) : super(const SearchState());

  final SearchRemoteDataSource _dataSource;

  void setQuery(String query) {
    state = state.copyWith(query: query, clearError: true);
  }

  void clearQuery() {
    state = const SearchState();
  }

  void setMusicOnly({required bool value}) {
    state = state.copyWith(musicOnly: value);
    // Re-search if we have a query
    if (state.query.isNotEmpty && state.hasSearched) {
      search(state.query);
    }
  }

  void setSearchTab(SearchTabType tab) {
    if (state.searchTab == tab) return;
    // Set isSearching: true immediately to prevent flash of empty state
    // when tab switches and search is triggered
    state = state.copyWith(
      searchTab: tab,
      results: const [],
      userResults: const [],
      hasSearched: false,
      isSearching: state.query.isNotEmpty,
      currentPage: 1,
      totalPages: 0,
    );
    // Re-search if we have a query
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(
      query: query,
      isSearching: true,
      clearError: true,
      currentPage: 1,
      results: const [],
      userResults: const [],
    );

    try {
      if (state.searchTab == SearchTabType.video) {
        final result = await _dataSource.searchVideo(
          keyword: query,
          tids: state.musicOnly ? 3 : 0,
        );
        state = state.copyWith(
          isSearching: false,
          hasSearched: true,
          results: result.result,
          currentPage: result.page,
          totalPages: result.numPages,
        );
      } else {
        final result = await _dataSource.searchUser(
          keyword: query,
        );
        state = state.copyWith(
          isSearching: false,
          hasSearched: true,
          userResults: result.result,
          currentPage: result.page,
          totalPages: result.numPages,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        hasSearched: true,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.query.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      if (state.searchTab == SearchTabType.video) {
        final result = await _dataSource.searchVideo(
          keyword: state.query,
          page: nextPage,
          tids: state.musicOnly ? 3 : 0,
        );
        state = state.copyWith(
          isLoadingMore: false,
          results: [...state.results, ...result.result],
          currentPage: result.page,
          totalPages: result.numPages,
        );
      } else {
        final result = await _dataSource.searchUser(
          keyword: state.query,
          page: nextPage,
        );
        state = state.copyWith(
          isLoadingMore: false,
          userResults: [...state.userResults, ...result.result],
          currentPage: result.page,
          totalPages: result.numPages,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dataSource = ref.watch(searchDataSourceProvider);
  return SearchNotifier(dataSource);
});

/// Search screen for finding content.
///
/// Source: biu/src/pages/search/index.tsx#Search
/// Source: biu/src/pages/search/search-type.tsx#SearchType
/// Source: biu/src/pages/search/video-list.tsx#VideoList
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final tab =
          _tabController.index == 0 ? SearchTabType.video : SearchTabType.user;
      ref.read(searchNotifierProvider.notifier).setSearchTab(tab);
    }
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search header
          _buildSearchHeader(context, searchState),
          // Tab bar (only show when we have search results)
          if (searchState.hasSearched) _buildTabBar(context, searchState),
          // Content area
          Expanded(
            child: _buildContent(context, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, SearchState searchState) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: '搜索视频、音乐、用户...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textTertiary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(searchNotifierProvider.notifier)
                                    .clearQuery();
                                ref
                                    .read(searchSuggestionsProvider.notifier)
                                    .clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(searchNotifierProvider.notifier).setQuery(value);
                      // Fetch search suggestions with debounce
                      ref
                          .read(searchSuggestionsProvider.notifier)
                          .updateQuery(value);
                      setState(() {});
                    },
                    onSubmitted: _performSearch,
                  ),
                ),
              ],
            ),
            // Music only toggle (only for video search)
            if (searchState.searchTab == SearchTabType.video)
              _buildMusicOnlyToggle(context, searchState),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicOnlyToggle(BuildContext context, SearchState searchState) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '仅音乐',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: searchState.musicOnly,
            onChanged: (value) {
              ref.read(searchNotifierProvider.notifier).setMusicOnly(value: value);
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, SearchState searchState) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '视频'),
          Tab(text: '用户'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState searchState) {
    if (searchState.isSearching) {
      return const LoadingState(message: '搜索中...');
    }

    if (searchState.error != null) {
      return EmptyState(
        icon: const Icon(
          Icons.error_outline,
          size: 48,
          color: AppColors.error,
        ),
        title: '搜索失败',
        message: '请稍后重试',
        action: ElevatedButton(
          onPressed: () => _performSearch(searchState.query),
          child: const Text('重试'),
        ),
      );
    }

    if (searchState.hasSearched) {
      if (searchState.searchTab == SearchTabType.video) {
        return _buildVideoSearchResults(context, searchState);
      } else {
        return _buildUserSearchResults(context, searchState);
      }
    }

    // Show search suggestions and history when not searched
    return _buildSearchSuggestions(context);
  }

  Widget _buildVideoSearchResults(
      BuildContext context, SearchState searchState) {
    final results = searchState.results;
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.search_off,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: '无结果',
        message: '未找到相关视频',
      );
    }

    final displayMode = ref.watch(displayModeProvider);

    // Source: biu/src/pages/search/video-list.tsx
    // Search results don't show duration on cover badge
    // Use MediaActionMenu for consistent action menu across the app
    if (displayMode == DisplayMode.list) {
      // List view mode
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: results.length + (searchState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= results.length) {
            // Loading more indicator
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: searchState.isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }
          final video = results[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVideoListItem(context, video),
          );
        },
      );
    }

    // Grid view mode (default)
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length + (searchState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          // Loading more indicator
          return Center(
            child: searchState.isLoadingMore
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          );
        }
        final video = results[index];
        return _buildVideoCardItem(context, video);
      },
    );
  }

  /// Build video list item (list mode).
  Widget _buildVideoListItem(BuildContext context, SearchVideoItem video) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _playVideo(video),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image (no duration badge in search results)
              _buildVideoCover(video.pic),
              const SizedBox(width: 12),
              // Info section
              Expanded(child: _buildVideoInfo(context, video)),
              // Action menu
              MediaActionMenu(
                title: video.titlePlain,
                bvid: video.bvid,
                aid: video.aid.toString(),
                cover: video.pic,
                ownerName: video.author,
                ownerMid: video.mid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build video card item (grid mode).
  Widget _buildVideoCardItem(BuildContext context, SearchVideoItem video) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _playVideo(video),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.contentBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image (no duration badge in search results)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCachedImage(
                      imageUrl: video.pic,
                      fileType: FileType.video,
                    ),
                    // Action menu button
                    Positioned(
                      right: 4,
                      top: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: MediaActionMenu(
                          title: video.titlePlain,
                          bvid: video.bvid,
                          aid: video.aid.toString(),
                          cover: video.pic,
                          ownerName: video.author,
                          ownerMid: video.mid,
                          iconSize: 18,
                          iconColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildVideoCardInfo(context, video),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCover(String? coverUrl) {
    return SizedBox(
      width: 120,
      height: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: AppCachedImage(
          imageUrl: coverUrl,
          fileType: FileType.video,
        ),
      ),
    );
  }

  Widget _buildVideoInfo(BuildContext context, SearchVideoItem video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with highlight
        HighlightedText(
          text: video.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        // Owner
        GestureDetector(
          onTap: video.mid > 0 ? () => context.push('/user/${video.mid}') : null,
          child: Text(
            video.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: 4),
        // Stats
        Row(
          children: [
            if (video.play != null) ...[
              const Icon(Icons.play_arrow, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Text(
                NumberUtils.formatCompact(video.play),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVideoCardInfo(BuildContext context, SearchVideoItem video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with highlight
        HighlightedText(
          text: video.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        // Owner
        GestureDetector(
          onTap: video.mid > 0 ? () => context.push('/user/${video.mid}') : null,
          child: Text(
            video.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: 4),
        // Stats
        Row(
          children: [
            if (video.play != null) ...[
              const Icon(Icons.play_arrow, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 2),
              Text(
                NumberUtils.formatCompact(video.play),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUserSearchResults(
      BuildContext context, SearchState searchState) {
    final results = searchState.userResults;
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icon(
          Icons.search_off,
          size: 48,
          color: AppColors.textTertiary,
        ),
        title: '无结果',
        message: '未找到相关用户',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: results.length + (searchState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          // Loading more indicator
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: searchState.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }
        final user = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UserSearchCard(
            user: user,
            onTap: () => _openUserProfile(user),
          ),
        );
      },
    );
  }

  void _playVideo(SearchVideoItem video) {
    // Check if bvid is available
    if (video.bvid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('视频ID不可用')),
      );
      return;
    }

    // Note: Don't pass cid here, it will be fetched from video info
    // The search result only has aid, not cid
    final playItem = PlayItem(
      id: '${video.bvid}_1',
      type: PlayDataType.mv,
      bvid: video.bvid,
      aid: video.aid.toString(),
      title: video.titlePlain,
      cover: video.pic,
      ownerName: video.author,
      ownerMid: video.mid,
      duration: video.duration,
    );
    ref.read(playlistProvider.notifier).play(playItem);
  }

  /// Navigate to user profile screen.
  /// Source: biu/src/pages/search/user-list.tsx:25
  void _openUserProfile(SearchUserItem user) {
    context.push(AppRoutes.userSpacePath(user.mid));
  }

  /// Build search suggestions showing search history and suggestions.
  ///
  /// Source: biu/src/layout/navbar/search/index.tsx
  /// Shows search history as chips and live suggestions as list items.
  Widget _buildSearchSuggestions(BuildContext context) {
    final suggestionsState = ref.watch(searchSuggestionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search history section
          SearchHistoryWidget(
            onSelect: (query) {
              _searchController.text = query;
              _performSearch(query);
            },
          ),
          // Search suggestions section (from API)
          if (suggestionsState.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            SearchSuggestionsList(
              suggestions: suggestionsState.suggestions,
              onSelect: (query) {
                _searchController.text = query;
                _performSearch(query);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    _searchFocusNode.unfocus();
    // Clear suggestions
    ref.read(searchSuggestionsProvider.notifier).clear();
    // Add to search history
    ref.read(searchHistoryProvider.notifier).add(query);
    // Perform search
    ref.read(searchNotifierProvider.notifier).search(query);
  }
}
