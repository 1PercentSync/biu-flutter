# Implementation Tasks - Parity Report Decisions Alignment

## Agent Instructions

This task list implements decisions from MIGRATION_PARITY_REPORT.md analysis. Each task includes:
- Exact file locations and line numbers
- Source project references for alignment
- Expected code patterns

**Verification after each phase:**
1. Ensure code compiles: `flutter analyze`
2. Run tests if applicable: `flutter test`

**Reference Documents:**
- `MIGRATION_PARITY_REPORT.md` - Original analysis
- `FILE_MAPPING.md` - Source-to-target file mapping

---

## Phase 1: Remove Flutter-Only Features

### 1.1 Remove Hot Searches (Decision 3.2.A)

**Rationale:** Source project (`biu`) has no hot search feature. This was incorrectly added to Flutter.

#### 1.1.1 Remove Hot Searches Provider
- [ ] Location: `lib/features/search/presentation/providers/`
- [ ] Find and remove `hotSearchKeywordsProvider` or equivalent
- [ ] Remove any state related to hot search keywords

#### 1.1.2 Remove Hot Searches API Call
- [ ] Location: `lib/features/search/data/datasources/search_remote_datasource.dart`
- [ ] Find line ~201 (referenced in report)
- [ ] Remove `getHotSearchKeywords()` method or equivalent
- [ ] Remove related response models if unused elsewhere

#### 1.1.3 Remove Hot Searches UI
- [ ] Location: `lib/features/search/presentation/screens/search_screen.dart`
- [ ] Find line ~662 (referenced in report): `ref.watch(hotSearchKeywordsProvider)`
- [ ] Remove Hot Searches section from `_buildSearchSuggestions()` method
- [ ] Keep Search History section intact
- [ ] Verify search screen still compiles and functions

**Expected result:** Search suggestions show only search history, no trending/hot searches.

---

### 1.2 Remove Privacy/Terms from About (Decision 3.2.B)

**Rationale:** Source project has no About page with Privacy/Terms. These are Flutter-specific additions.

#### 1.2.1 Remove Privacy Policy Section
- [ ] Location: `lib/features/settings/presentation/screens/about_screen.dart`
- [ ] Find lines ~127-134 (Privacy Policy tile)
- [ ] Remove the `_buildLinkTile` for Privacy Policy
- [ ] Remove `_showInfoDialog` for privacy content if only used here

#### 1.2.2 Remove Terms of Service Section
- [ ] Location: `lib/features/settings/presentation/screens/about_screen.dart`
- [ ] Find Terms of Service tile (after Privacy Policy)
- [ ] Remove the `_buildLinkTile` for Terms
- [ ] Remove related dialog content

#### 1.2.3 Keep Open Source Licenses
- [ ] Verify lines ~103-125 (Open Source Licenses) remain intact
- [ ] This uses Flutter's standard `showLicensePage()` - keep it
- [ ] Source: Standard Flutter feature, acceptable for mobile

**Expected result:** About screen shows only app info and Open Source Licenses.

---

### 1.3 Remove Downloads Entry (Decision 3.1.A)

**Rationale:** Download system is desktop-only (`biu/electron/ipc/download/*`). Mobile will not implement this.

#### 1.3.1 Remove Downloads Menu Item
- [ ] Location: `lib/features/profile/presentation/screens/profile_screen.dart`
- [ ] Find lines ~153-158:
  ```dart
  _buildMenuItem(
    context,
    icon: Icons.download,
    title: 'Downloads',
    onTap: () {
      // TODO: Navigate to downloads
    },
  ),
  ```
- [ ] Remove entire `_buildMenuItem` block for Downloads
- [ ] Verify profile screen still compiles

**Expected result:** Profile menu no longer shows Downloads option.

---

### 1.4 Remove Unused Route Constants (Decision 3.2.C/6.3)

**Rationale:** Source project has no `/video/:bvid` or `/audio/:sid` routes. These constants create false expectations.

#### 1.4.1 Remove Route Constants
- [ ] Location: `lib/core/router/routes.dart`
- [ ] Remove lines ~42-45:
  ```dart
  /// Video detail page
  static const String videoDetail = '/video/:bvid';

  /// Audio detail page
  static const String audioDetail = '/audio/:sid';
  ```

#### 1.4.2 Remove Path Builder Functions
- [ ] Location: `lib/core/router/routes.dart`
- [ ] Remove lines ~54-57:
  ```dart
  /// Build video detail path
  static String videoDetailPath(String bvid) => '/video/$bvid';

  /// Build audio detail path
  static String audioDetailPath(int sid) => '/audio/$sid';
  ```

#### 1.4.3 Verify No References
- [ ] Run: `grep -r "videoDetail\|audioDetail" lib/`
- [ ] If any references exist, remove them or update to use appropriate routes
- [ ] Verify compilation: `flutter analyze`

**Expected result:** No unused route constants in codebase.

---

## Phase 2: Fix User Navigation (Decision 3.1.D/6.2)

### 2.1 Enable Search User Navigation

**Source reference:** `biu/src/pages/search/user-list.tsx:25`
```tsx
onClick={() => navigate(`/user/${data.mid}`)}
```

#### 2.1.1 Update Search Screen User Tap Handler
- [ ] Location: `lib/features/search/presentation/screens/search_screen.dart`
- [ ] Find lines ~654-658:
  ```dart
  void _openUserProfile(SearchUserItem user) {
    // TODO: Navigate to user profile screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User: ${user.uname}')),
    );
  }
  ```
- [ ] Replace with navigation:
  ```dart
  /// Navigate to user profile screen.
  /// Source: biu/src/pages/search/user-list.tsx:25
  void _openUserProfile(SearchUserItem user) {
    context.push(AppRoutes.userSpacePath(user.mid));
  }
  ```
- [ ] Verify import for `go_router` extension methods exists

**Expected result:** Tapping user in search results navigates to user profile.

---

### 2.2 Enable Artist Rank User Navigation

**Source reference:** `biu/src/pages/artist-rank/index.tsx:62`
```tsx
onClick={() => navigate(`/user/${item.uid}`)}
```

#### 2.2.1 Update Artist Rank Musician Tap Handler
- [ ] Location: `lib/features/artist_rank/presentation/screens/artist_rank_screen.dart`
- [ ] Find lines ~107-117:
  ```dart
  void _onMusicianTap(Musician musician) {
    // Navigate to user profile
    // TODO: Navigate to user profile screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opening ${musician.username}'s profile..."),
        duration: const Duration(seconds: 1),
      ),
    );
    // For now, we can try to navigate if the route exists
    // context.push('/user/${musician.uid}');
  }
  ```
- [ ] Replace with navigation:
  ```dart
  /// Navigate to musician's user profile.
  /// Source: biu/src/pages/artist-rank/index.tsx:62
  void _onMusicianTap(Musician musician) {
    context.push(AppRoutes.userSpacePath(musician.uid));
  }
  ```

**Expected result:** Tapping musician card navigates to their user profile.

---

## Phase 3: Complete User Profile Tabs (Decision 3.1.C)

**Source reference:** `biu/src/pages/user-profile/index.tsx:96-118`
```tsx
const tabs = [
  { label: "动态", key: "dynamic", content: <DynamicList mid={Number(id)} ... /> },
  { label: "投稿", key: "video", content: <VideoPost /> },
  { label: "收藏夹", key: "collection", hidden: !isSelf && !spacePrivacy?.fav_video, content: <Favorites /> },
  { label: "合集", key: "union", content: <VideoSeries /> },
].filter(item => !item.hidden);
```

### 3.1 Add Dynamic Tab

#### 3.1.1 Create Dynamic Feed API
- [ ] Location: `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`
- [ ] Add method to fetch user dynamics
- [ ] API endpoint: `/x/polymer/web-dynamic/v1/feed/space`
- [ ] Source reference: `biu/src/service/space-dynamic-list.ts`
- [ ] Parameters:
  ```dart
  /// Fetch user dynamic feed.
  /// Source: biu/src/service/space-dynamic-list.ts
  Future<DynamicFeedResponse> getDynamicFeed({
    required int hostMid,
    String? offset,
    int? timezone,
  });
  ```

#### 3.1.2 Create Dynamic Models
- [ ] Location: `lib/features/user_profile/data/models/dynamic_item.dart`
- [ ] Create models matching source response structure
- [ ] Source reference: `biu/src/pages/user-profile/dynamic-list/index.tsx`
- [ ] Key fields: `id_str`, `modules` (author, desc, dynamic, stat), `type`

#### 3.1.3 Create DynamicList Widget
- [ ] Location: `lib/features/user_profile/presentation/widgets/dynamic_list.dart`
- [ ] Source reference: `biu/src/pages/user-profile/dynamic-list/index.tsx`
- [ ] Pattern:
  ```dart
  /// User dynamic feed list widget.
  /// Source: biu/src/pages/user-profile/dynamic-list/index.tsx
  class DynamicList extends ConsumerStatefulWidget {
    const DynamicList({super.key, required this.mid});
    final int mid;
    // ...
  }
  ```
- [ ] Implement infinite scroll with offset pagination
- [ ] Display dynamic cards (video, text, forward types)

#### 3.1.4 Create DynamicCard Widget
- [ ] Location: `lib/features/user_profile/presentation/widgets/dynamic_card.dart`
- [ ] Source reference: `biu/src/pages/user-profile/dynamic-list/dynamic-card.tsx`
- [ ] Handle different dynamic types:
  - `DYNAMIC_TYPE_AV` - Video
  - `DYNAMIC_TYPE_DRAW` - Image
  - `DYNAMIC_TYPE_WORD` - Text only
  - `DYNAMIC_TYPE_FORWARD` - Repost

---

### 3.2 Add Video Series (Union) Tab

#### 3.2.1 Create Video Series API
- [ ] Location: `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`
- [ ] Add method to fetch user's video series list
- [ ] API endpoint: `/x/polymer/web-space/seasons_series_list`
- [ ] Source reference: `biu/src/service/space-seasons-series-list.ts`
- [ ] Parameters:
  ```dart
  /// Fetch user's video series (seasons) list.
  /// Source: biu/src/service/space-seasons-series-list.ts
  Future<SeasonsSeriesListResponse> getSeasonsSeriesList({
    required int mid,
    int pageNum = 1,
    int pageSize = 20,
  });
  ```

#### 3.2.2 Create Video Series Models
- [ ] Location: `lib/features/user_profile/data/models/video_series.dart`
- [ ] Create models for seasons and series
- [ ] Source reference: `biu/src/pages/user-profile/video-series.tsx`
- [ ] Key structures:
  ```dart
  /// Video series (season) item.
  /// Source: biu/src/pages/user-profile/video-series.tsx
  class VideoSeriesItem {
    final int seasonId;
    final String name;
    final String cover;
    final int total;
    // ...
  }
  ```

#### 3.2.3 Create VideoSeriesTab Widget
- [ ] Location: `lib/features/user_profile/presentation/widgets/video_series_tab.dart`
- [ ] Source reference: `biu/src/pages/user-profile/video-series.tsx`
- [ ] Display grid of series with cover, title, count
- [ ] Tap to navigate to series detail (use existing folder detail pattern)

---

### 3.3 Update User Profile Screen Tabs

#### 3.3.1 Add New Tabs to Tab Configuration
- [ ] Location: `lib/features/user_profile/presentation/screens/user_profile_screen.dart`
- [ ] Find `_updateTabs` method around line ~79
- [ ] Current tabs: `['video', 'favorites']`
- [ ] Update to match source:
  ```dart
  /// Build tabs based on privacy settings.
  /// Source: biu/src/pages/user-profile/index.tsx:96-118
  void _updateTabs(UserProfileState state, int? currentUserId, bool isSelf) {
    final newTabs = <_ProfileTab>[
      const _ProfileTab(key: 'dynamic', label: 'Dynamic'),
      const _ProfileTab(key: 'video', label: 'Videos'),
      _ProfileTab(
        key: 'favorites',
        label: 'Favorites',
        hidden: !isSelf && !state.shouldShowFavoritesTab(currentUserId),
      ),
      const _ProfileTab(key: 'union', label: 'Series'),
    ].where((tab) => !tab.hidden).toList();
    // ...
  }
  ```

#### 3.3.2 Add Tab Content Builders
- [ ] Add case for 'dynamic' tab → `DynamicList(mid: widget.mid)`
- [ ] Add case for 'union' tab → `VideoSeriesTab(mid: widget.mid)`
- [ ] Ensure all 4 tabs have content

**Expected result:** User profile shows 4 tabs matching source project.

---

## Phase 4: Fix Password Recovery (Decision 3.3.B)

**Source reference:** `biu/src/layout/navbar/login/password-login.tsx:175-177`
```tsx
onPress={() =>
  window.electron.openExternal("https://passport.bilibili.com/pc/passport/findPassword")
}
```

### 4.1 Add url_launcher Dependency
- [ ] Check if `url_launcher` is in pubspec.yaml
- [ ] If not, add: `url_launcher: ^6.2.0`
- [ ] Run: `flutter pub get`

### 4.2 Update Password Login Widget

#### 4.2.1 Add Import
- [ ] Location: `lib/features/auth/presentation/widgets/password_login_widget.dart`
- [ ] Add import:
  ```dart
  import 'package:url_launcher/url_launcher.dart';
  ```

#### 4.2.2 Create Password Recovery Handler
- [ ] Find password recovery button/link (around line ~150)
- [ ] Replace current dialog behavior with browser launch:
  ```dart
  /// Open password recovery page in system browser.
  /// Source: biu/src/layout/navbar/login/password-login.tsx:175-177
  Future<void> _openPasswordRecovery() async {
    final uri = Uri.parse('https://passport.bilibili.com/pc/passport/findPassword');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open password recovery page')),
        );
      }
    }
  }
  ```

#### 4.2.3 Update UI Element
- [ ] Find the password recovery trigger (icon button or text link)
- [ ] Update `onTap`/`onPressed` to call `_openPasswordRecovery()`
- [ ] Keep tooltip/label: "Forgot Password" or similar

**Expected result:** Tapping password recovery opens system browser with Bilibili page.

---

## Phase 5: Refactor Module Boundaries (Decision 5.2.A/5.2.B)

### 5.1 Fix core → feature Dependency (5.2.A)

**Problem:** `GaiaVgateInterceptor` in core imports from features/auth.

**Source reference:** `biu/src/service/request/response-interceptors.ts` (Geetest verification)

#### 5.1.1 Create Abstraction Interface in Core
- [ ] Location: `lib/core/network/gaia_vgate/gaia_vgate_handler.dart` (new file)
- [ ] Create abstract interface:
  ```dart
  /// Abstract handler for Gaia VGate risk control verification.
  ///
  /// This abstraction allows core network layer to trigger verification
  /// without depending on feature layer implementations.
  ///
  /// Source concept: biu/src/service/request/response-interceptors.ts
  abstract class GaiaVgateHandler {
    /// Register Gaia VGate challenge and get Geetest parameters.
    Future<GaiaVgateRegisterResult?> register({required String vVoucher});

    /// Show Geetest verification dialog and get result.
    Future<GeetestResult?> showVerification({
      required String token,
      required String gt,
      required String challenge,
    });

    /// Validate Geetest result and get grisk_id.
    Future<String?> validate({
      required String token,
      required String challenge,
      required String validate,
      required String seccode,
    });
  }

  /// Result from Gaia VGate register API.
  class GaiaVgateRegisterResult {
    final String token;
    final String? gt;
    final String? challenge;
    // ...
  }

  /// Result from Geetest verification.
  class GeetestResult {
    final String challenge;
    final String validate;
    final String seccode;
    // ...
  }
  ```

#### 5.1.2 Create Handler Provider in Core
- [ ] Location: `lib/core/network/gaia_vgate/gaia_vgate_provider.dart` (new file)
- [ ] Create provider that will be set by app initialization:
  ```dart
  /// Provider for Gaia VGate handler.
  /// Must be initialized before network requests.
  final gaiaVgateHandlerProvider = StateProvider<GaiaVgateHandler?>((ref) => null);
  ```

#### 5.1.3 Implement Handler in Auth Feature
- [ ] Location: `lib/features/auth/data/services/gaia_vgate_handler_impl.dart` (new file)
- [ ] Implement the interface using existing auth datasource and geetest dialog:
  ```dart
  /// Implementation of GaiaVgateHandler using auth feature components.
  /// Source: biu/src/service/request/response-interceptors.ts
  class GaiaVgateHandlerImpl implements GaiaVgateHandler {
    GaiaVgateHandlerImpl({
      required this.authDatasource,
      required this.navigatorKey,
    });

    final AuthRemoteDatasource authDatasource;
    final GlobalKey<NavigatorState> navigatorKey;

    @override
    Future<GaiaVgateRegisterResult?> register({required String vVoucher}) async {
      // Use authDatasource.registerGaiaVgate
    }

    @override
    Future<GeetestResult?> showVerification({...}) async {
      // Use GeetestDialog.show with navigator context
    }

    @override
    Future<String?> validate({...}) async {
      // Use authDatasource.validateGaiaVgate
    }
  }
  ```

#### 5.1.4 Update Interceptor to Use Interface
- [ ] Location: `lib/core/network/interceptors/gaia_vgate_interceptor.dart`
- [ ] Remove imports from features/auth
- [ ] Use the abstract handler interface:
  ```dart
  import '../gaia_vgate/gaia_vgate_handler.dart';
  import '../gaia_vgate/gaia_vgate_provider.dart';

  /// Interceptor for handling Bilibili Gaia VGate risk control.
  /// Source: biu/src/service/request/response-interceptors.ts#geetestInterceptors
  class GaiaVgateInterceptor extends Interceptor {
    GaiaVgateInterceptor({required this.ref});
    final Ref ref;

    GaiaVgateHandler? get _handler => ref.read(gaiaVgateHandlerProvider);

    @override
    Future<void> onResponse(...) async {
      // Use _handler instead of direct auth datasource calls
    }
  }
  ```

#### 5.1.5 Initialize Handler at App Startup
- [ ] Location: `lib/main.dart` or app initialization
- [ ] After providers are ready, set the handler:
  ```dart
  // Initialize Gaia VGate handler
  container.read(gaiaVgateHandlerProvider.notifier).state = GaiaVgateHandlerImpl(
    authDatasource: container.read(authRemoteDatasourceProvider),
    navigatorKey: navigatorKey,
  );
  ```

---

### 5.2 Fix shared → feature Dependency (5.2.B)

**Problem:** `FullPlayerScreen` in shared imports `FolderSelectSheet` from features/favorites.

**Source reference:** `biu/src/layout/playbar/right/mv-fav-folder-select.tsx`

#### 5.2.1 Option A: Move FolderSelectSheet to Shared (Recommended)
- [ ] Location: Move from `lib/features/favorites/presentation/widgets/folder_select_sheet.dart`
- [ ] To: `lib/shared/widgets/folder_select_sheet.dart`
- [ ] Update all imports in codebase
- [ ] Pattern:
  ```dart
  /// Bottom sheet for selecting a favorites folder.
  /// Source: biu/src/layout/playbar/right/mv-fav-folder-select.tsx
  class FolderSelectSheet extends ConsumerWidget {
    // ...
  }
  ```

#### 5.2.2 Update Imports
- [ ] Update `full_player_screen.dart` import path
- [ ] Update any other files importing FolderSelectSheet
- [ ] Verify: `grep -r "folder_select_sheet" lib/`

#### 5.2.3 Handle Dependencies
- [ ] FolderSelectSheet may depend on favorites providers
- [ ] Either:
  - Move required providers to shared/providers
  - Accept favorites provider dependency in shared (less ideal)
- [ ] Keep the favorites datasource in features (data layer separation)

**Expected result:**
- `lib/core/` has zero imports from `lib/features/`
- `lib/shared/` has zero imports from `lib/features/`

---

## Verification Tasks

### V.1 Compile Check
- [ ] Run `flutter analyze` - zero errors
- [ ] Run `flutter build apk --debug` - builds successfully

### V.2 Import Verification
- [ ] Run: `grep -r "import.*features" lib/core/`
- [ ] Expected: Zero results
- [ ] Run: `grep -r "import.*features" lib/shared/`
- [ ] Expected: Zero results

### V.3 Feature Removal Verification
- [ ] Search screen: No hot searches section
- [ ] About screen: No Privacy/Terms tiles
- [ ] Profile screen: No Downloads menu item
- [ ] Routes.dart: No videoDetail/audioDetail

### V.4 Navigation Verification
- [ ] Search for user → Navigate to user profile works
- [ ] Artist rank musician tap → Navigate to user profile works

### V.5 User Profile Verification
- [ ] User profile shows 4 tabs: Dynamic, Videos, Favorites, Series
- [ ] Dynamic tab loads and displays content
- [ ] Video Series tab loads and displays content

### V.6 Password Recovery Verification
- [ ] Tap password recovery → System browser opens Bilibili page

---

## File Change Summary

### Files to DELETE
- None (all changes are modifications)

### Files to CREATE
- `lib/core/network/gaia_vgate/gaia_vgate_handler.dart`
- `lib/core/network/gaia_vgate/gaia_vgate_provider.dart`
- `lib/features/auth/data/services/gaia_vgate_handler_impl.dart`
- `lib/features/user_profile/data/models/dynamic_item.dart`
- `lib/features/user_profile/data/models/video_series.dart`
- `lib/features/user_profile/presentation/widgets/dynamic_list.dart`
- `lib/features/user_profile/presentation/widgets/dynamic_card.dart`
- `lib/features/user_profile/presentation/widgets/video_series_tab.dart`

### Files to MODIFY
- `lib/features/search/presentation/screens/search_screen.dart`
- `lib/features/search/data/datasources/search_remote_datasource.dart`
- `lib/features/settings/presentation/screens/about_screen.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/artist_rank/presentation/screens/artist_rank_screen.dart`
- `lib/features/auth/presentation/widgets/password_login_widget.dart`
- `lib/features/user_profile/presentation/screens/user_profile_screen.dart`
- `lib/features/user_profile/data/datasources/user_profile_remote_datasource.dart`
- `lib/core/router/routes.dart`
- `lib/core/network/interceptors/gaia_vgate_interceptor.dart`
- `lib/shared/widgets/playbar/full_player_screen.dart`
- `lib/main.dart` (handler initialization)

### Files to MOVE
- `lib/features/favorites/presentation/widgets/folder_select_sheet.dart` → `lib/shared/widgets/folder_select_sheet.dart`
