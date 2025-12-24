import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Search state notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void clearQuery() {
    state = const SearchState();
  }
}

/// Search state
class SearchState {
  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.hasSearched = false,
  });

  final String query;
  final bool isSearching;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    bool? isSearching,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

/// Search screen for finding content.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search header
          _buildSearchHeader(context),
          // Content area
          Expanded(
            child: _buildContent(context, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                            ref.read(searchNotifierProvider.notifier).clearQuery();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  ref.read(searchNotifierProvider.notifier).setQuery(value);
                  setState(() {});
                },
                onSubmitted: _performSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState searchState) {
    if (searchState.query.isEmpty) {
      return _buildSearchSuggestions(context);
    }

    // TODO: Implement actual search results
    return const EmptyState(
      icon: Icon(
        Icons.search_off,
        size: 48,
        color: AppColors.textTertiary,
      ),
      title: 'Search',
      message: 'Enter keywords to search for content',
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search history section
          _buildSectionHeader(context, 'Search History'),
          const SizedBox(height: 12),
          const EmptyState(
            message: 'No search history',
          ),
          const SizedBox(height: 24),
          // Hot searches section
          _buildSectionHeader(context, 'Hot Searches'),
          const SizedBox(height: 12),
          _buildHotSearches(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (title == 'Search History')
          TextButton(
            onPressed: () {
              // TODO: Clear history
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
      ],
    );
  }

  Widget _buildHotSearches() {
    // Placeholder hot searches
    final hotSearches = [
      'Popular Music',
      'Trending Videos',
      'Game Soundtracks',
      'Anime Music',
      'Live Performances',
    ];

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
    // TODO: Implement actual search
  }
}
