# Technical Design - Parity Report Decisions Alignment

## Context

This change addresses consistency violations identified in MIGRATION_PARITY_REPORT.md. The most significant technical challenges are:

1. **Module Boundary Violations** - core and shared layers incorrectly depend on feature layer
2. **User Profile Enhancement** - Adding two new tabs with their own APIs and widgets
3. **Maintaining Source Parity** - Ensuring all changes align with source project patterns

## Goals / Non-Goals

### Goals
- Achieve 1:1 feature parity with source project for implemented features
- Maintain clean module boundaries per Flutter/Dart best practices
- Provide clear source references for all implementations
- Enable future maintenance by following established patterns

### Non-Goals
- Adding features beyond source project scope
- Performance optimization (unless required for parity)
- Redesigning existing working implementations
- Breaking existing functionality

## Key Decisions

### D1: Module Boundary Fix Strategy

**Decision:** Use dependency injection via Riverpod providers for cross-layer communication.

**Context:**
- `GaiaVgateInterceptor` (core) needs to trigger Geetest verification (feature/auth)
- `FullPlayerScreen` (shared) needs folder selection (feature/favorites)
- Direct imports create circular/incorrect dependencies

**Approach:**
```
BEFORE:
core/network/interceptor.dart → features/auth/datasource.dart  ❌
shared/playbar/player.dart → features/favorites/sheet.dart    ❌

AFTER:
core/network/gaia_vgate/handler.dart (abstract interface)
  ↑ implements
features/auth/services/handler_impl.dart
  ↓ uses
core/network/interceptor.dart (via provider)                   ✅

shared/widgets/folder_select_sheet.dart (moved to shared)     ✅
```

**Alternatives Considered:**
1. **Callback approach** - Pass callbacks from features to core
   - Rejected: Creates tight coupling, hard to test
2. **Event bus** - Use global event system
   - Rejected: Adds complexity, harder to trace
3. **Keep as-is with documentation** - Accept the violation
   - Rejected: Technical debt, blocks proper testing

**Trade-offs:**
- (+) Clean separation of concerns
- (+) Testable with mock implementations
- (-) Slightly more boilerplate code
- (-) Runtime dependency on provider initialization

### D2: Dynamic Tab API Design

**Decision:** Use Bilibili's polymer/web-dynamic API with offset-based pagination.

**Source Reference:** `biu/src/service/space-dynamic-list.ts`

**API Details:**
```
GET /x/polymer/web-dynamic/v1/feed/space
Parameters:
  - host_mid: int (user ID)
  - offset: string (pagination cursor)
  - timezone_offset: int (default: -480)

Response:
  - items: List<DynamicItem>
  - offset: string (next page cursor)
  - has_more: bool
```

**Model Mapping:**
```dart
/// Source: biu/src/pages/user-profile/dynamic-list/index.tsx
class DynamicItem {
  final String idStr;
  final String type;  // DYNAMIC_TYPE_AV, DYNAMIC_TYPE_DRAW, etc.
  final DynamicModules modules;
}

class DynamicModules {
  final ModuleAuthor moduleAuthor;
  final ModuleDesc? moduleDesc;
  final ModuleDynamic moduleDynamic;
  final ModuleStat moduleStat;
}
```

### D3: Video Series Tab API Design

**Decision:** Use space/seasons_series_list API with page-based pagination.

**Source Reference:** `biu/src/service/space-seasons-series-list.ts`

**API Details:**
```
GET /x/polymer/web-space/seasons_series_list
Parameters:
  - mid: int (user ID)
  - page_num: int (1-based)
  - page_size: int (default: 20)

Response:
  - items_lists: {
      seasons_list: List<SeasonItem>
      series_list: List<SeriesItem>
    }
  - page: { total, page_num, page_size }
```

**UI Decision:**
- Display seasons and series in unified grid
- Use existing folder card pattern for consistency
- Tap navigates to series detail (reuse FolderDetailScreen pattern)

### D4: Folder Selection Widget Location

**Decision:** Move `FolderSelectSheet` to shared layer.

**Rationale:**
- Widget is used by player (shared) and favorites (feature)
- Player is a cross-cutting concern, needs folder access
- Moving to shared prevents feature→feature dependency

**Migration Path:**
1. Move file: `features/favorites/widgets/` → `shared/widgets/`
2. Update all imports
3. Keep favorites data layer intact (API calls stay in features)
4. Pass folder data via Riverpod providers (already in place)

**Source Alignment:**
- Source: `biu/src/layout/playbar/right/mv-fav-folder-select.tsx`
- This is in layout (shared equivalent), not pages (feature equivalent)
- Our move aligns with source structure

### D5: Password Recovery Implementation

**Decision:** Use `url_launcher` with `LaunchMode.externalApplication`.

**Source Reference:** `biu/src/layout/navbar/login/password-login.tsx:176`
```tsx
window.electron.openExternal("https://passport.bilibili.com/pc/passport/findPassword")
```

**Flutter Equivalent:**
```dart
await launchUrl(
  Uri.parse('https://passport.bilibili.com/pc/passport/findPassword'),
  mode: LaunchMode.externalApplication,
);
```

**Platform Considerations:**
- iOS: Opens Safari
- Android: Opens default browser
- Both match "openExternal" behavior from Electron

## Risks / Trade-offs

### R1: GaiaVgate Handler Late Initialization
- **Risk:** If handler isn't set before first API call, verification fails
- **Mitigation:** Initialize handler in `main.dart` before `runApp()`
- **Fallback:** Interceptor skips verification if handler is null (already implemented)

### R2: Dynamic Tab Performance
- **Risk:** Complex dynamic content may be slow to render
- **Mitigation:** Use lazy loading, cache rendered widgets
- **Monitoring:** Add debug prints for load times

### R3: File Move Breaking Imports
- **Risk:** Moving `folder_select_sheet.dart` may break imports
- **Mitigation:** Use IDE refactor or careful grep+replace
- **Verification:** `flutter analyze` must pass after move

## Migration Plan

### Phase Order (Recommended)
1. **Phase 1 (Removals)** - Safest, no new code
2. **Phase 2 (Navigation)** - Simple fixes
3. **Phase 4 (Password Recovery)** - Simple addition
4. **Phase 5 (Module Boundaries)** - Infrastructure change
5. **Phase 3 (User Profile Tabs)** - Most complex, needs Phase 5

### Rollback Strategy
- Each phase can be reverted independently
- Git commits per phase enable targeted rollback
- No database/state migrations required

## Open Questions

1. **Q: Should folder search/filter be moved to shared too?**
   - A: No, keep in favorites feature. Player only needs selection, not management.

2. **Q: What if dynamic API requires authentication?**
   - A: Hide dynamic tab for non-authenticated users (match source behavior)

3. **Q: Should we add tests for new code?**
   - A: Yes, at minimum:
     - Unit test for GaiaVgateHandler interface
     - Widget test for user navigation
     - Integration test for dynamic API

## File Structure After Changes

```
lib/
├── core/
│   ├── network/
│   │   ├── gaia_vgate/
│   │   │   ├── gaia_vgate_handler.dart      # NEW: Abstract interface
│   │   │   └── gaia_vgate_provider.dart     # NEW: Provider
│   │   └── interceptors/
│   │       └── gaia_vgate_interceptor.dart  # MODIFIED: Use interface
│   └── router/
│       └── routes.dart                       # MODIFIED: Remove unused routes
│
├── features/
│   ├── auth/
│   │   ├── data/services/
│   │   │   └── gaia_vgate_handler_impl.dart # NEW: Implementation
│   │   └── presentation/widgets/
│   │       └── password_login_widget.dart   # MODIFIED: url_launcher
│   │
│   ├── user_profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── user_profile_remote_datasource.dart  # MODIFIED: New APIs
│   │   │   └── models/
│   │   │       ├── dynamic_item.dart        # NEW
│   │   │       └── video_series.dart        # NEW
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── user_profile_screen.dart # MODIFIED: 4 tabs
│   │       └── widgets/
│   │           ├── dynamic_list.dart        # NEW
│   │           ├── dynamic_card.dart        # NEW
│   │           └── video_series_tab.dart    # NEW
│   │
│   ├── search/
│   │   ├── data/datasources/
│   │   │   └── search_remote_datasource.dart  # MODIFIED: Remove hot search
│   │   └── presentation/screens/
│   │       └── search_screen.dart             # MODIFIED: Remove hot search, fix nav
│   │
│   ├── artist_rank/
│   │   └── presentation/screens/
│   │       └── artist_rank_screen.dart      # MODIFIED: Fix navigation
│   │
│   ├── settings/
│   │   └── presentation/screens/
│   │       └── about_screen.dart            # MODIFIED: Remove Privacy/Terms
│   │
│   └── profile/
│       └── presentation/screens/
│           └── profile_screen.dart          # MODIFIED: Remove Downloads
│
└── shared/
    └── widgets/
        ├── folder_select_sheet.dart         # MOVED from features/favorites
        └── playbar/
            └── full_player_screen.dart      # MODIFIED: Update import
```
