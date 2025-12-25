# user_profile Module Internal Parity Audit Report

## Overview

**Module Path**: `biu_flutter/lib/features/user_profile/`

**Audit Date**: 2025-12-25

**Source References**:
- `biu/src/pages/user-profile/index.tsx` - Main profile page
- `biu/src/pages/user-profile/video-tab.tsx` - Video tab (maps to video content in screen)
- `biu/src/pages/user-profile/dynamic-list/index.tsx` - Dynamic list
- `biu/src/pages/user-profile/dynamic-list/item.tsx` - Dynamic item card
- `biu/src/pages/user-profile/video-series.tsx` - Video series tab
- `biu/src/pages/user-profile/favorites.tsx` - Favorites tab
- `biu/src/pages/user-profile/space-info.tsx` - Space info header
- `biu/src/service/space-wbi-acc-info.ts` - User info API
- `biu/src/service/space-seasons-series-list.ts` - Seasons/series API
- `biu/src/service/web-dynamic.ts` - Dynamic feed API

---

## Structure Score: 4.5/5

The user_profile module demonstrates **excellent** alignment with the source project while following Flutter/Dart best practices and Clean Architecture principles.

---

## Module Structure

### Target Project Structure
```
user_profile/
├── data/
│   ├── datasources/
│   │   └── user_profile_remote_datasource.dart
│   └── models/
│       ├── dynamic_item.dart
│       ├── space_acc_info.dart
│       ├── space_arc_search.dart
│       ├── space_relation.dart
│       ├── space_setting.dart
│       └── video_series.dart
├── presentation/
│   ├── providers/
│   │   ├── user_profile_notifier.dart
│   │   └── user_profile_state.dart
│   ├── screens/
│   │   └── user_profile_screen.dart
│   └── widgets/
│       ├── dynamic_card.dart
│       ├── dynamic_list.dart
│       ├── space_info_header.dart
│       ├── user_favorites_tab.dart
│       ├── video_post_card.dart
│       └── video_series_tab.dart
└── user_profile.dart (barrel export)
```

### Source-to-Target Mapping

| Source File | Target File | Status |
|-------------|-------------|--------|
| `pages/user-profile/index.tsx` | `presentation/screens/user_profile_screen.dart` | Implemented |
| `pages/user-profile/dynamic-list/index.tsx` | `presentation/widgets/dynamic_list.dart` | Implemented |
| `pages/user-profile/dynamic-list/item.tsx` | `presentation/widgets/dynamic_card.dart` | Implemented |
| `pages/user-profile/video-series.tsx` | `presentation/widgets/video_series_tab.dart` | Implemented |
| `pages/user-profile/favorites.tsx` | `presentation/widgets/user_favorites_tab.dart` | Implemented |
| `pages/user-profile/video-post.tsx` | `presentation/widgets/video_post_card.dart` | Implemented |
| `pages/user-profile/space-info.tsx` | `presentation/widgets/space_info_header.dart` | Implemented |
| `service/space-wbi-acc-info.ts` | `data/datasources/user_profile_remote_datasource.dart` | Implemented |
| `service/web-dynamic.ts` | `data/datasources/user_profile_remote_datasource.dart` | Implemented |
| `service/space-seasons-series-list.ts` | `data/datasources/user_profile_remote_datasource.dart` | Implemented |

---

## Detailed Analysis

### 1. Data Layer

#### Datasources

**UserProfileRemoteDataSource** (`data/datasources/user_profile_remote_datasource.dart`)

**Strengths**:
- Comprehensive API coverage with 7 endpoint methods
- Proper WBI signing for required endpoints (`useWbi: true`)
- Well-defined exception classes for different error scenarios
- Good error code handling (e.g., -400, -403, -404, -352)
- Source references documented in comments

**APIs Covered**:
1. `getSpaceAccInfo` - User detailed info
2. `getSpaceRelation` - Relation with current user
3. `getRelationStat` - Relation statistics
4. `getSpaceVideos` - User video list with search/filter
5. `getSpaceSetting` - Privacy settings
6. `getSeasonsSeriesList` - Video series/seasons
7. `getDynamicFeed` - User dynamic feed

#### Models

**Comprehensive model coverage**:

1. **space_acc_info.dart** (566 lines)
   - Complete mapping of `SpaceAccInfo` with all nested types
   - Includes VIP info, official verification, pendant, nameplate, live room
   - Proper computed properties (`isBanned`, `isVerified`, `isVip`)

2. **dynamic_item.dart** (1067 lines)
   - Extensive mapping of dynamic feed structure
   - Supports multiple content types (video, draw, opus, article, music, live)
   - `DynamicType` constants matching source project
   - Well-structured nested models (modules, major, additional, etc.)

3. **video_series.dart** (189 lines)
   - Proper parsing of both seasons and series items
   - Distinction between `fromSeasonJson` and `fromSeriesJson`
   - Pagination info included

4. **space_relation.dart** (134 lines)
   - `UserRelation` enum with proper values
   - Helper methods (`isFollowing`, `isMutual`, `isBlocked`)

5. **space_setting.dart** (90 lines)
   - Complete privacy settings mapping
   - `isFavoritesVisible` helper property

6. **space_arc_search.dart** (204 lines)
   - Video list with category statistics
   - Duration parsing (`durationSeconds` computed property)

### 2. Presentation Layer

#### Providers

**UserProfileNotifier** (`presentation/providers/user_profile_notifier.dart`)

**Strengths**:
- Uses family provider pattern for mid-based instances
- Proper initialization flow (`_init` method)
- State management for multiple data types (videos, folders)
- Follow/unfollow toggle with state refresh
- Good separation of concerns

**UserProfileState** (`presentation/providers/user_profile_state.dart`)

**Strengths**:
- Immutable state with `copyWith` pattern
- Multiple loading states tracked separately
- Privacy-aware tab visibility (`shouldShowFavoritesTab`)
- Computed properties for relation checks

#### Screens

**UserProfileScreen** (`presentation/screens/user_profile_screen.dart`)

**Strengths**:
- Dynamic tab management based on privacy settings
- Scroll-based infinite loading for videos
- RefreshIndicator for pull-to-refresh
- Tab content rendered via TabBarView

**Matching Source Behavior**:
- 4 tabs: Dynamic, Videos, Favorites, Series
- Favorites tab hidden based on privacy (matching source line 110)
- Blocked user handling (matching source line 136)

#### Widgets

1. **DynamicList** - Self-managing scroll and pagination (matching source behavior)
2. **DynamicCard** - Rich content display with video playback
3. **VideoSeriesTab** - Grid layout with load-more support
4. **UserFavoritesTab** - Grid display of user folders
5. **VideoPostCard** - Card and list tile variants
6. **SpaceInfoHeader** - Background image, avatar, stats display

---

## Justified Deviations

### 1. State Management Pattern
- **Source**: Uses ahooks (`useRequest`, `usePagination`)
- **Target**: Uses Riverpod with StateNotifier
- **Justification**: Flutter's recommended approach; provides better type safety and testability

### 2. DynamicList Self-Contained State
- **Source**: Dynamic list receives `scrollElement` prop
- **Target**: DynamicList manages its own ScrollController
- **Justification**: More encapsulated; Flutter's ListView handles scrolling internally

### 3. Single Datasource Class
- **Source**: Multiple service files for different APIs
- **Target**: Single `UserProfileRemoteDataSource` class
- **Justification**: Clean Architecture pattern; related APIs grouped together

### 4. No Domain Layer
- **Target**: Skips domain layer (no entities/repositories)
- **Justification**: Simple CRUD operations don't require abstraction; models serve directly

---

## Issues Found

### Issue 1: Dynamic Tab Only Shows Video Types [Low]

**File**: `presentation/widgets/dynamic_list.dart:92-96`

```dart
// Filter to only show video dynamics (matching source behavior)
final videos = data.items
    .where((item) => item.type == DynamicType.av)
    .toList();
```

**Analysis**: This correctly matches source project behavior (line 43 in source), but the naming `videos` is slightly misleading. The source also filters for `DynamicType.Av` only.

**Recommendation**: This is correct behavior. No change needed.

### Issue 2: Video Series Navigation Uses Different Route [Low]

**File**: `presentation/widgets/video_series_tab.dart:198`

```dart
context.push('/collection/${item.id}?type=video_series');
```

**Source**: Uses `CollectionType.VideoSeries` constant

**Recommendation**: Consider using a constant instead of hardcoded string for consistency.

### Issue 3: UserProfileNotifier Dependencies on Other Features [Low]

**File**: `presentation/providers/user_profile_notifier.dart:4-5`

```dart
import '../../../favorites/data/datasources/favorites_remote_datasource.dart';
import '../../../follow/data/datasources/follow_remote_datasource.dart';
```

**Analysis**: Cross-feature dependencies for loading folders and follow/unfollow operations.

**Recommendation**: This is acceptable as these are data-layer dependencies. Could be abstracted via interfaces if needed in future.

### Issue 4: Missing Barrel Export for user_favorites_tab [Low]

**File**: `user_profile.dart`

```dart
// Does not export user_favorites_tab.dart
```

**Recommendation**: Add export for `user_favorites_tab.dart` if it needs to be used externally.

---

## Verification of Prior Decisions

### Dynamic Tab Implementation
**Status**: VERIFIED

The dynamic tab is fully implemented with:
- `DynamicList` widget handling pagination
- `DynamicCard` widget for item display
- API integration via `getDynamicFeed`
- Proper filtering for video-type dynamics (matching source)

### Series/Union Tab Implementation
**Status**: VERIFIED

The series tab is fully implemented with:
- `VideoSeriesTab` widget
- Grid layout display
- Pagination support
- Navigation to collection detail

### Tab Visibility Logic
**Status**: VERIFIED

Matches source implementation:
- Dynamic, Videos, Series always visible
- Favorites visible only for self OR when `spacePrivacy.fav_video === 1`

---

## Code Quality Assessment

### Strengths

1. **Comprehensive API Coverage**: All required APIs are implemented
2. **Rich Data Models**: Extensive model coverage for complex API responses
3. **Clean Widget Separation**: Each tab is its own widget
4. **Proper Error Handling**: Exception classes for different scenarios
5. **Source References**: Good documentation with source file references
6. **Type Safety**: Proper null handling throughout

### Areas for Improvement

1. **Number Formatting**: Duplicated `_formatNumber` in multiple files (could extract to utility)
2. **Date Formatting**: Similar duplication for date formatting
3. **Error UI**: Could benefit from more specific error messages

---

## Summary

| Category | Score |
|----------|-------|
| Structure Alignment | 5/5 |
| API Coverage | 5/5 |
| Data Model Quality | 5/5 |
| Code Quality | 4/5 |
| Documentation | 4/5 |
| **Overall** | **4.5/5** |

The user_profile module is **well-implemented** and meets all requirements from the prior decisions:
- Dynamic tab is fully functional
- Series tab is fully functional
- Tab visibility follows source logic
- Clean Architecture principles are followed
- Code quality is high with minor room for improvement

**Issues Found**: 4 (all Low severity)
**Key Findings**:
- All 4 tabs implemented (Dynamic, Videos, Favorites, Series)
- Proper privacy-based tab visibility
- Comprehensive API and model coverage
- Self-managing widget states for tabs
