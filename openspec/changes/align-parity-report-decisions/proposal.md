# Change: Align Flutter with Migration Parity Report Decisions

## Why

MIGRATION_PARITY_REPORT.md identified multiple consistency violations between biu (Electron) and biu_flutter (Flutter). User decisions have been made for each issue. This change implements those decisions to achieve functional parity while maintaining clean module boundaries.

Key issues addressed:
1. **Feature Over-Implementation** - Flutter has features the source doesn't have (Hot Searches, Privacy/Terms)
2. **Missing User Navigation** - User profile entry points are incomplete (search, artist rank)
3. **User Profile Tabs Incomplete** - Missing Dynamic and Video Series tabs
4. **Password Recovery UX** - Should open browser instead of showing dialog
5. **Module Boundary Violations** - core/shared layers incorrectly depend on feature layer

## What Changes

### Phase 1: Remove Flutter-Only Features

1. **Remove Hot Searches** (3.2.A)
   - Remove `hotSearchKeywordsProvider` from search screen
   - Remove `getHotSearchKeywords()` from search datasource
   - Source reference: N/A (source project has no hot search feature)

2. **Remove Privacy/Terms from About** (3.2.B)
   - Remove Privacy Policy dialog
   - Remove Terms of Service dialog
   - Keep Open Source Licenses (standard Flutter feature)
   - Source reference: `biu/src/pages/settings/index.tsx` (no About page with these features)

3. **Remove Downloads Entry** (3.1.A)
   - Remove Downloads menu item from profile screen
   - Source reference: Download system is desktop-only (`biu/electron/ipc/download/*`)

4. **Remove Unused Route Constants** (3.2.C/6.3)
   - Remove `videoDetail` and `audioDetail` from routes.dart
   - Remove corresponding path builder functions
   - Source reference: `biu/src/routes.tsx` (no such routes)

### Phase 2: Fix User Navigation (3.1.D/6.2)

5. **Enable Search User Navigation**
   - Replace TODO with actual navigation to user profile
   - Location: `search_screen.dart:654-658`
   - Source reference: `biu/src/pages/search/user-list.tsx:25`

6. **Enable Artist Rank User Navigation**
   - Replace TODO with actual navigation to user profile
   - Location: `artist_rank_screen.dart:107-117`
   - Source reference: `biu/src/pages/artist-rank/index.tsx:62`

### Phase 3: Complete User Profile Tabs (3.1.C)

7. **Add Dynamic Tab**
   - Create DynamicList widget
   - Implement dynamic feed API
   - Source reference: `biu/src/pages/user-profile/dynamic-list/index.tsx`

8. **Add Video Series (Union) Tab**
   - Create VideoSeriesTab widget
   - Implement seasons archives API
   - Source reference: `biu/src/pages/user-profile/index.tsx:114-117`

### Phase 4: Fix Password Recovery (3.3.B)

9. **Open Browser for Password Recovery**
   - Use `url_launcher` to open Bilibili password recovery page
   - Replace current dialog-only behavior
   - Source reference: `biu/src/layout/navbar/login/password-login.tsx:176`

### Phase 5: Refactor Module Boundaries (5.2.A/5.2.B)

10. **Fix core → feature Dependency**
    - Extract Gaia VGate verification interface to core layer
    - Move implementation details to auth feature
    - Location: `core/network/interceptors/gaia_vgate_interceptor.dart`

11. **Fix shared → feature Dependency**
    - Move `FolderSelectSheet` to shared layer OR
    - Create abstraction that doesn't require feature import
    - Location: `shared/widgets/playbar/full_player_screen.dart`

## Impact

- **Affected specs**:
  - user-profile (MODIFIED - add tabs)
  - search (MODIFIED - remove hot searches)
  - settings (MODIFIED - remove about features)
  - authentication (MODIFIED - password recovery)
  - core-infrastructure (MODIFIED - module boundaries)

- **Affected code**:
  - `lib/features/search/` - Remove hot searches, fix navigation
  - `lib/features/settings/` - Remove Privacy/Terms
  - `lib/features/profile/` - Remove Downloads
  - `lib/features/artist_rank/` - Fix navigation
  - `lib/features/user_profile/` - Add tabs
  - `lib/features/auth/` - Fix password recovery
  - `lib/core/router/` - Remove unused routes
  - `lib/core/network/` - Fix module boundary
  - `lib/shared/widgets/` - Fix module boundary

- **Breaking changes**: None (feature removals are for non-source features)

## Source Reference Mapping

| Flutter Change | Source Location | Action |
|----------------|-----------------|--------|
| Hot Searches | N/A | REMOVE |
| Privacy/Terms | N/A | REMOVE |
| Downloads entry | `biu/electron/ipc/download/*` (desktop-only) | REMOVE |
| videoDetail route | N/A | REMOVE |
| User navigation (search) | `biu/src/pages/search/user-list.tsx:25` | FIX |
| User navigation (artist) | `biu/src/pages/artist-rank/index.tsx:62` | FIX |
| Dynamic tab | `biu/src/pages/user-profile/dynamic-list/` | ADD |
| Video series tab | `biu/src/pages/user-profile/index.tsx:114-117` | ADD |
| Password recovery | `biu/src/layout/navbar/login/password-login.tsx:176` | FIX |
| GaiaVgate interceptor | `biu/src/service/request/response-interceptors.ts` | REFACTOR |
| FolderSelectSheet | `biu/src/layout/playbar/right/mv-fav-folder-select.tsx` | REFACTOR |

## Success Criteria

1. No Hot Searches UI or API calls in search
2. About screen has only Open Source Licenses
3. Profile screen has no Downloads entry
4. Tapping user in search navigates to user profile
5. Tapping musician in artist rank navigates to user profile
6. User profile has 4 tabs: Dynamic, Videos, Favorites, Video Series
7. Password recovery opens system browser
8. `lib/core/` has no imports from `lib/features/`
9. `lib/shared/` has no imports from `lib/features/`
10. All changes compile without errors: `flutter analyze`
