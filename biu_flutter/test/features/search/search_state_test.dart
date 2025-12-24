import 'package:biu_flutter/features/search/presentation/screens/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchState', () {
    test('default state has musicOnly = true', () {
      const state = SearchState();
      expect(state.musicOnly, true);
      expect(state.query, '');
      expect(state.isSearching, false);
      expect(state.hasSearched, false);
      expect(state.results, isEmpty);
      expect(state.searchTab, SearchTabType.video);
    });

    test('musicOnly toggle works correctly', () {
      const state = SearchState(musicOnly: true);
      final newState = state.copyWith(musicOnly: false);
      expect(newState.musicOnly, false);
    });

    test('hasMore returns true when currentPage < totalPages', () {
      const state = SearchState(currentPage: 1, totalPages: 5);
      expect(state.hasMore, true);
    });

    test('hasMore returns false when currentPage >= totalPages', () {
      const state = SearchState(currentPage: 5, totalPages: 5);
      expect(state.hasMore, false);
    });

    test('copyWith preserves other fields when only musicOnly changes', () {
      const state = SearchState(
        query: 'test query',
        isSearching: false,
        hasSearched: true,
        musicOnly: true,
        currentPage: 2,
        totalPages: 10,
      );

      final newState = state.copyWith(musicOnly: false);

      expect(newState.query, 'test query');
      expect(newState.hasSearched, true);
      expect(newState.musicOnly, false);
      expect(newState.currentPage, 2);
      expect(newState.totalPages, 10);
    });

    test('searchTab changes correctly', () {
      const state = SearchState(searchTab: SearchTabType.video);
      final newState = state.copyWith(searchTab: SearchTabType.user);
      expect(newState.searchTab, SearchTabType.user);
    });
  });

  group('SearchTabType', () {
    test('enum values exist', () {
      expect(SearchTabType.values, contains(SearchTabType.video));
      expect(SearchTabType.values, contains(SearchTabType.user));
    });
  });
}
