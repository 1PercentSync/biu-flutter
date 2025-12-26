import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/search_remote_datasource.dart';
import '../../data/models/search_suggest.dart';

/// State for search suggestions.
class SearchSuggestionsState {
  const SearchSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.query = '',
  });

  final List<SearchSuggestItem> suggestions;
  final bool isLoading;
  final String query;

  SearchSuggestionsState copyWith({
    List<SearchSuggestItem>? suggestions,
    bool? isLoading,
    String? query,
  }) {
    return SearchSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
    );
  }
}

/// Notifier for search suggestions with debounce.
///
/// Source: biu/src/layout/navbar/search/index.tsx
/// Uses debounce to prevent excessive API calls while typing.
class SearchSuggestionsNotifier extends StateNotifier<SearchSuggestionsState> {
  SearchSuggestionsNotifier(this._dataSource)
      : super(const SearchSuggestionsState());

  final SearchRemoteDataSource _dataSource;
  Timer? _debounceTimer;

  /// Debounce duration in milliseconds (same as source project: 300ms)
  static const _debounceDuration = Duration(milliseconds: 300);

  /// Update query and fetch suggestions with debounce.
  void updateQuery(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update query immediately (for UI state tracking)
    state = state.copyWith(query: query);

    // Clear suggestions if query is empty
    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }

    // Set up debounced fetch
    _debounceTimer = Timer(_debounceDuration, () {
      _fetchSuggestions(query);
    });
  }

  /// Fetch suggestions from API.
  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }

    state = state.copyWith(isLoading: true);
    developer.log('Fetching suggestions for: $query', name: 'SearchSuggestions');

    try {
      final suggestions = await _dataSource.getSearchSuggestions(
        keyword: query,
      );
      developer.log('Got ${suggestions.length} suggestions', name: 'SearchSuggestions');
      // Only update if query hasn't changed
      if (state.query == query) {
        state = state.copyWith(
          suggestions: suggestions,
          isLoading: false,
        );
      }
    } catch (e, stack) {
      developer.log('Error fetching suggestions: $e', name: 'SearchSuggestions', error: e, stackTrace: stack);
      // Silently fail - suggestions are not critical
      if (state.query == query) {
        state = state.copyWith(
          suggestions: [],
          isLoading: false,
        );
      }
    }
  }

  /// Clear suggestions.
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchSuggestionsState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for search suggestions.
final searchSuggestionsProvider =
    StateNotifierProvider<SearchSuggestionsNotifier, SearchSuggestionsState>(
        (ref) {
  final dataSource = SearchRemoteDataSource();
  return SearchSuggestionsNotifier(dataSource);
});
