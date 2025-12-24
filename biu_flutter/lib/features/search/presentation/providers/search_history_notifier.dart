import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/search_history_item.dart';

/// Storage key for search history
const _storageKey = 'search_history';

/// Maximum number of history items to store
const _maxHistoryItems = 50;

/// Search history state
class SearchHistoryState {
  const SearchHistoryState({
    this.items = const [],
    this.isLoaded = false,
  });

  final List<SearchHistoryItem> items;
  final bool isLoaded;

  SearchHistoryState copyWith({
    List<SearchHistoryItem>? items,
    bool? isLoaded,
  }) {
    return SearchHistoryState(
      items: items ?? this.items,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// Search history notifier with persistence
class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  SearchHistoryNotifier(this._storage) : super(const SearchHistoryState()) {
    _load();
  }

  final StorageService _storage;

  /// Load history from storage
  Future<void> _load() async {
    try {
      final jsonStr = await _storage.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
        final items = jsonList
            .map((e) => SearchHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(items: items, isLoaded: true);
      } else {
        state = state.copyWith(isLoaded: true);
      }
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  /// Save history to storage
  Future<void> _save() async {
    try {
      final jsonList = state.items.map((e) => e.toJson()).toList();
      await _storage.setString(_storageKey, json.encode(jsonList));
    } catch (_) {
      // Ignore save errors
    }
  }

  /// Add a search term to history
  void add(String value) {
    if (value.trim().isEmpty) return;

    final trimmedValue = value.trim();
    final newItem = SearchHistoryItem(
      value: trimmedValue,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Remove existing item with same value (if any)
    final filteredItems =
        state.items.where((item) => item.value != trimmedValue).toList();

    // Add new item at the beginning
    final newItems = [newItem, ...filteredItems];

    // Limit to max items
    final limitedItems = newItems.length > _maxHistoryItems
        ? newItems.sublist(0, _maxHistoryItems)
        : newItems;

    state = state.copyWith(items: limitedItems);
    _save();
  }

  /// Delete a specific history item
  void delete(SearchHistoryItem item) {
    final newItems = state.items.where((i) => i.value != item.value).toList();
    state = state.copyWith(items: newItems);
    _save();
  }

  /// Clear all history
  void clear() {
    state = state.copyWith(items: const []);
    _save();
  }
}

/// Provider for search history
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SearchHistoryNotifier(storage);
});
