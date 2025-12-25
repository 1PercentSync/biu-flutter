# Later Module Audit Report

## Summary

| Item | Value |
|------|-------|
| Module | later |
| Target Path | `biu_flutter/lib/features/later/` |
| Structure Score | **4/5** |
| Issues Found | 2 |
| Audit Date | 2025-12-25 |

## Source Project Mapping

| Source File | Target File | Status |
|-------------|-------------|--------|
| `pages/later/index.tsx` | `presentation/screens/later_screen.dart` | Implemented |
| `service/history-toview-list.ts` | `data/datasources/later_remote_datasource.dart` | Implemented |
| `service/history-toview-add.ts` | `data/datasources/later_remote_datasource.dart` | Implemented |
| `service/history-toview-del.ts` | `data/datasources/later_remote_datasource.dart` | Implemented |
| `service/history-toview-clear.ts` | `data/datasources/later_remote_datasource.dart` | Implemented (via `removeFromWatchLater(viewed: true)`) |

## Module Structure

```
later/
├── later.dart                           # Barrel export file
├── data/
│   ├── datasources/
│   │   └── later_remote_datasource.dart # API calls
│   └── models/
│       └── watch_later_item.dart        # Data models
└── presentation/
    ├── providers/
    │   ├── later_notifier.dart          # State management
    │   └── later_state.dart             # State definition
    ├── screens/
    │   └── later_screen.dart            # Main screen
    └── widgets/
        └── later_item_card.dart         # Item card widget
```

## Justified Deviations (Not Issues)

### 1. No Domain Layer
**Deviation**: Module lacks a `domain/` directory with entities/repositories.

**Justification**: For simple CRUD modules like "Watch Later", skipping the domain layer reduces boilerplate. The module's business logic is straightforward (list/add/remove items) and doesn't require complex domain abstractions. This matches the pattern used in the `history` module, maintaining internal consistency within the project.

### 2. Infinite Scroll vs Pagination
**Deviation**: Source uses traditional pagination with page numbers; target uses infinite scroll.

**Justification**: Infinite scroll is the standard UX pattern for mobile apps. The underlying API still uses page-based pagination (`pn` parameter), but the presentation layer implements infinite scroll for better mobile UX. This is an intentional improvement.

### 3. Different Display Modes
**Deviation**: Source has card/list display mode toggle; target only uses list mode.

**Justification**: The target implementation uses a custom `LaterItemCard` widget that combines the best aspects of both modes - showing cover, title, author, progress, and duration in a compact layout suitable for mobile screens.

## Issues Found

### Issue 1: Missing WBI Signature [Medium]

**File**: `data/datasources/later_remote_datasource.dart`

**Description**: The `getWatchLaterList` API call does not use WBI signature, but the source project explicitly requires it:

Source (`history-toview-list.ts`):
```typescript
export async function getHistoryToViewList(params: HistoryToViewListParams): Promise<HistoryToViewListResponse> {
  return apiRequest.get<HistoryToViewListResponse>("/x/v2/history/toview/web", {
    params,
    useWbi: true,  // <-- WBI required
  });
}
```

Target (`later_remote_datasource.dart`):
```dart
final response = await _dio.get<Map<String, dynamic>>(
  '/x/v2/history/toview/web',
  queryParameters: {
    'pn': pn,
    'ps': ps,
    'viewed': viewed,
  },
  // Missing: options: Options(extra: {'useWbi': true})
);
```

**Impact**: API calls may fail or return errors if the B站 backend enforces WBI signature verification for this endpoint.

**Recommendation**: Add WBI signature option:
```dart
final response = await _dio.get<Map<String, dynamic>>(
  '/x/v2/history/toview/web',
  queryParameters: {...},
  options: Options(extra: {'useWbi': true}),
);
```

### Issue 2: Code Style - Empty Lines in Function Calls [Low]

**File**: `presentation/providers/later_notifier.dart`

**Description**: There are empty lines inside function call parentheses at lines 37-39 and 112-114:

```dart
final response = await _dataSource.getWatchLaterList(

);
```

Should be:
```dart
final response = await _dataSource.getWatchLaterList();
```

**Impact**: No functional impact, but violates Dart style guidelines.

## Positive Findings

### 1. Complete API Coverage
All four source service files (list/add/del/clear) are properly implemented in a single datasource file, following the Flutter convention of consolidating related API calls.

### 2. Proper Error Handling
Custom exception classes are defined for specific error scenarios:
- `LaterNotLoggedInException` - code -101
- `LaterListFullException` - code 90001
- `LaterVideoNotExistException` - code 90003

This matches the error codes documented in the source TypeScript types.

### 3. Comprehensive Data Model
`WatchLaterItem` includes all fields from source `ToViewVideoItem`:
- Core fields: aid, bvid, title, pic, duration, cid
- Nested objects: owner, stat, dimension
- Helper methods: durationFormatted, progressRatio, addAtFormatted

### 4. Correct Difference from History Module
The later module correctly differs from history in these ways:

| Aspect | History | Later |
|--------|---------|-------|
| Pagination | Cursor-based | Page-based |
| API | `/x/web-interface/history/cursor` | `/x/v2/history/toview/web` |
| Filter | `type: archive` | `viewed: 0` |
| Delete capability | No | Yes |
| Add capability | No | Yes |

### 5. Proper Provider Architecture
Uses Riverpod's `StateNotifierProvider` pattern consistently with:
- Separate state class (`LaterState`)
- Immutable state with `copyWith`
- Proper provider for datasource injection

### 6. Mobile-Optimized UI
- RefreshIndicator for pull-to-refresh
- SliverAppBar for smooth scrolling behavior
- Infinite scroll with load-more indicator
- Confirm dialog for delete action

## Comparison with History Module

| Aspect | Later | History | Assessment |
|--------|-------|---------|------------|
| Structure | data + presentation | data + presentation | Consistent |
| Datasource | Single file, 4 APIs | Single file, 1 API | Appropriate |
| Model | `WatchLaterItem` | `HistoryItem` | Different APIs, correct |
| State | `LaterState` | `HistoryState` | Similar pattern |
| Notifier | `LaterNotifier` | `HistoryNotifier` | Similar pattern |
| Widget | `LaterItemCard` | `HistoryItemCard` | Similar pattern |
| Screen | `LaterScreen` | `HistoryScreen` | Similar pattern |

## Clean Architecture Assessment

| Layer | Status | Notes |
|-------|--------|-------|
| Data/Datasources | Pass | Properly wraps API calls |
| Data/Models | Pass | Correctly maps API responses |
| Domain | N/A | Intentionally omitted (justified) |
| Presentation/Providers | Pass | Follows Riverpod patterns |
| Presentation/Screens | Pass | Clean widget structure |
| Presentation/Widgets | Pass | Single responsibility |

## Recommendations

1. **[Required]** Add WBI signature to `getWatchLaterList` API call
2. **[Optional]** Clean up empty lines in `later_notifier.dart`
3. **[Consider]** Add unit tests for `LaterNotifier` state transitions

## Conclusion

The later module is well-implemented with a clean structure that properly follows Clean Architecture principles and Riverpod patterns. The main issue is the missing WBI signature which should be addressed to ensure API compatibility. The module correctly differentiates itself from the history module in terms of pagination strategy and available operations (add/delete).

**Overall Grade: 4/5** - Good implementation with one medium-priority fix needed.
