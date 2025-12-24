import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/audio.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/video_card.dart';
import '../../../later/presentation/providers/later_notifier.dart';
import '../../../player/domain/entities/play_item.dart';
import '../../../player/presentation/providers/playlist_notifier.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../data/models/search_result.dart';
import '../providers/search_history_notifier.dart';
import '../widgets/search_history_widget.dart';
import '../widgets/user_search_card.dart';

/// Provider for search data source
final searchDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource();
});

/// Provider for hot search keywords
final hotSearchKeywordsProvider = FutureProvider<List<String>>((ref) async {
  final dataSource = ref.watch(searchDataSourceProvider);
  return dataSource.getHotSearchKeywords();
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

  void setMusicOnly(bool value) {
    state = state.copyWith(musicOnly: value);
    // Re-search if we have a query
    if (state.query.isNotEmpty && state.hasSearched) {
      search(state.query);
    }
  }

  void setSearchTab(SearchTabType tab) {
    if (state.searchTab == tab) return;
    state = state.copyWith(
      searchTab: tab,
      results: const [],
      userResults: const [],
      hasSearched: false,
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
  bool _showSearchHistory = false;

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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
    setState(() {
      _showSearchHistory =
          _searchFocusNode.hasFocus && _searchController.text.isEmpty;
    });
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
                      hintText: 'Search videos, music, users...',
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
                                setState(() {
                                  _showSearchHistory = _searchFocusNode.hasFocus;
                                });
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
                      setState(() {
                        _showSearchHistory =
                            _searchFocusNode.hasFocus && value.isEmpty;
                      });
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
            'Music Only',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: searchState.musicOnly,
            onChanged: (value) {
              ref.read(searchNotifierProvider.notifier).setMusicOnly(value);
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
          Tab(text: 'Videos'),
          Tab(text: 'Users'),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState searchState) {
    if (searchState.isSearching) {
      return const LoadingState(message: 'Searching...');
    }

    if (searchState.error != null) {
      return EmptyState(
        icon: const Icon(
          Icons.error_outline,
          size: 48,
          color: AppColors.error,
        ),
        title: 'Search Error',
        message: searchState.error,
        action: ElevatedButton(
          onPressed: () => _performSearch(searchState.query),
          child: const Text('Retry'),
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
        title: 'No Results',
        message: 'No videos found for your search',
      );
    }

    final displayMode = ref.watch(displayModeProvider);

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
            child: VideoListTile(
              title: video.title.stripHtml(),
              coverUrl: video.pic,
              ownerName: video.author,
              duration: video.duration,
              viewCount: video.play,
              onTap: () => _playVideo(video),
              actions: [
                VideoCardAction(
                  label: 'Watch Later',
                  icon: Icons.watch_later_outlined,
                  onTap: () => _addToWatchLater(video),
                ),
              ],
            ),
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
        return VideoCard(
          title: video.title.stripHtml(),
          coverUrl: video.pic,
          ownerName: video.author,
          duration: video.duration,
          viewCount: video.play,
          onTap: () => _playVideo(video),
          actions: [
            VideoCardAction(
              label: 'Watch Later',
              icon: Icons.watch_later_outlined,
              onTap: () => _addToWatchLater(video),
            ),
          ],
        );
      },
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
        title: 'No Results',
        message: 'No users found for your search',
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
        const SnackBar(content: Text('Video ID not available')),
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
      title: video.title.stripHtml(),
      cover: video.pic,
      ownerName: video.author,
      ownerMid: video.mid,
      duration: video.duration,
    );
    ref.read(playlistProvider.notifier).play(playItem);
  }

  Future<void> _addToWatchLater(SearchVideoItem video) async {
    try {
      final success = await ref.read(laterProvider.notifier).addItem(
            aid: video.aid,
            bvid: video.bvid,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to Watch Later'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        final error = ref.read(laterProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to add to Watch Later'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openUserProfile(SearchUserItem user) {
    // TODO: Navigate to user profile screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User: ${user.uname}')),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final hotSearches = ref.watch(hotSearchKeywordsProvider);

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
          const SizedBox(height: 24),
          // Hot searches section
          _buildSectionHeader(context, 'Hot Searches'),
          const SizedBox(height: 12),
          hotSearches.when(
            data: _buildHotSearches,
            loading: () => const LoadingIndicator(),
            error: (_, __) => _buildHotSearches(_fallbackHotSearches),
          ),
        ],
      ),
    );
  }

  static const _fallbackHotSearches = [
    'Popular Music',
    'Trending Videos',
    'Game Soundtracks',
    'Anime Music',
    'Live Performances',
  ];

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildHotSearches(List<String> hotSearches) {
    if (hotSearches.isEmpty) {
      return const EmptyState(message: 'No hot searches available');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hotSearches.map((search) {
        return ActionChip(
          label: Text(search),
          backgroundColor: AppColors.surface,
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          onPressed: () {
            _searchController.text = search;
            ref.read(searchNotifierProvider.notifier).setQuery(search);
            _performSearch(search);
          },
        );
      }).toList(),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchHistory = false;
    });
    // Add to search history
    ref.read(searchHistoryProvider.notifier).add(query);
    // Perform search
    ref.read(searchNotifierProvider.notifier).search(query);
  }
}
