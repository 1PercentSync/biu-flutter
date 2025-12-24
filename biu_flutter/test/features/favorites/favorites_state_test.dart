import 'package:biu_flutter/features/favorites/presentation/providers/favorites_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FolderDetailState', () {
    test('default state has empty selection', () {
      const state = FolderDetailState();

      expect(state.isSelectionMode, false);
      expect(state.selectedIds, isEmpty);
      expect(state.hasSelection, false);
      expect(state.selectedCount, 0);
    });

    test('selection mode can be toggled', () {
      const state = FolderDetailState();
      final newState = state.copyWith(isSelectionMode: true);

      expect(newState.isSelectionMode, true);
    });

    test('selectedIds can be updated', () {
      const state = FolderDetailState();
      final newState = state.copyWith(selectedIds: {1, 2, 3});

      expect(newState.selectedIds, {1, 2, 3});
      expect(newState.hasSelection, true);
      expect(newState.selectedCount, 3);
    });

    test('clearing selection resets selectedIds', () {
      final state = const FolderDetailState().copyWith(
        selectedIds: {1, 2, 3},
        isSelectionMode: true,
      );
      final newState = state.copyWith(
        selectedIds: {},
        isSelectionMode: false,
      );

      expect(newState.selectedIds, isEmpty);
      expect(newState.hasSelection, false);
      expect(newState.isSelectionMode, false);
    });

    test('keyword filter can be set', () {
      const state = FolderDetailState();
      final newState = state.copyWith(keyword: 'test query');

      expect(newState.keyword, 'test query');
    });

    test('sort order can be changed', () {
      const state = FolderDetailState();
      expect(state.order, FolderSortOrder.mtime); // default

      final newState = state.copyWith(order: FolderSortOrder.view);
      expect(newState.order, FolderSortOrder.view);

      final pubState = state.copyWith(order: FolderSortOrder.pubtime);
      expect(pubState.order, FolderSortOrder.pubtime);
    });
  });

  group('FolderSortOrder', () {
    test('enum has correct values', () {
      expect(FolderSortOrder.mtime.value, 'mtime');
      expect(FolderSortOrder.mtime.label, 'Favorite Time');

      expect(FolderSortOrder.view.value, 'view');
      expect(FolderSortOrder.view.label, 'View Count');

      expect(FolderSortOrder.pubtime.value, 'pubtime');
      expect(FolderSortOrder.pubtime.label, 'Publish Time');
    });
  });

  group('FavoritesListState', () {
    test('default state is empty', () {
      const state = FavoritesListState();

      expect(state.createdFolders, isEmpty);
      expect(state.collectedFolders, isEmpty);
      expect(state.createdTotal, 0);
      expect(state.collectedTotal, 0);
      expect(state.hasError, false);
    });

    test('hasError returns true when errorMessage is set', () {
      final state = const FavoritesListState().copyWith(
        errorMessage: 'Something went wrong',
      );

      expect(state.hasError, true);
    });

    test('clearError clears the error message', () {
      final state = const FavoritesListState().copyWith(
        errorMessage: 'Error',
      );
      final clearedState = state.copyWith(clearError: true);

      expect(clearedState.errorMessage, isNull);
      expect(clearedState.hasError, false);
    });
  });

  group('FolderSelectState', () {
    test('default state is empty', () {
      const state = FolderSelectState();

      expect(state.folders, isEmpty);
      expect(state.selectedIds, isEmpty);
      expect(state.hasChanges, false);
    });

    test('hasChanges detects added folders', () {
      final state = const FolderSelectState().copyWith(
        originalIds: [1, 2],
        selectedIds: [1, 2, 3],
      );

      expect(state.hasChanges, true);
    });

    test('hasChanges detects removed folders', () {
      final state = const FolderSelectState().copyWith(
        originalIds: [1, 2, 3],
        selectedIds: [1, 2],
      );

      expect(state.hasChanges, true);
    });

    test('hasChanges returns false when no changes', () {
      final state = const FolderSelectState().copyWith(
        originalIds: [1, 2, 3],
        selectedIds: [1, 2, 3],
      );

      expect(state.hasChanges, false);
    });

    test('hasChanges detects different folders even with same count', () {
      final state = const FolderSelectState().copyWith(
        originalIds: [1, 2, 3],
        selectedIds: [1, 2, 4],
      );

      expect(state.hasChanges, true);
    });
  });
}
