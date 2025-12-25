# Tasks: Apply Audit Fixes

> **Implementation Notes for Agents:**
> - Read `design.md` before starting implementation
> - Complete tasks in order (CRITICAL → Medium → Low)
> - Run `flutter analyze` after each task group
> - Commit after completing each numbered section (1.x, 2.x, etc.)
> - Reference exemplary modules: music_recommend, follow, shared/widgets

---

## 1. CRITICAL: Fix Compilation Error

### 1.1 Fix artist_rank uid type mismatch (#1)
**Files:**
- `biu_flutter/lib/features/artist_rank/data/models/musician.dart`
- `biu_flutter/lib/features/artist_rank/presentation/screens/artist_rank_screen.dart:112`

**Steps:**
1. Open `musician.dart`
2. Change `final String uid;` to `final int uid;`
3. Update fromJson: `uid: json['uid'] as int? ?? 0,`
4. Verify `artist_rank_screen.dart:112` now compiles (no change needed if model is fixed)
5. Search codebase for other `Musician.uid` usages and update if needed

**Verification:**
```bash
flutter analyze biu_flutter/lib/features/artist_rank/
```

---

## 2. Medium Priority: Functional Bugs

### 2.1 Add WBI signature to later API (#2)
**File:** `biu_flutter/lib/features/later/data/datasources/later_remote_datasource.dart`

**Steps:**
1. Find `getWatchLaterList` method
2. Add `options: Options(extra: {'useWbi': true})` to the dio.get call
3. Ensure `import 'package:dio/dio.dart';` includes Options

**Code Change:**
```dart
// Before
final response = await _dio.get<Map<String, dynamic>>(
  '/x/v2/history/toview/web',
  queryParameters: {...},
);

// After
final response = await _dio.get<Map<String, dynamic>>(
  '/x/v2/history/toview/web',
  queryParameters: {...},
  options: Options(extra: {'useWbi': true}),
);
```

### 2.2 Implement hidden folder filtering (#3)
**File:** `biu_flutter/lib/features/favorites/presentation/screens/favorites_screen.dart`

**Steps:**
1. Find where `createdFolders` or `collectedFolders` are displayed
2. Import `hiddenFolderIdsProvider` from settings
3. Watch the provider and filter folders before display

**Code Pattern:**
```dart
final hiddenIds = ref.watch(hiddenFolderIdsProvider);
final visibleFolders = folders.where((f) => !hiddenIds.contains(f.id)).toList();
```

### 2.3 Fix volume slider state in popup (#4)
**File:** `biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:492-545`

**Steps:**
1. Find the volume PopupMenuButton with StatefulBuilder
2. Replace StatefulBuilder pattern with Consumer widget
3. Use `ref.watch(playlistProvider.select((s) => s.volume))` inside Consumer

**Code Change:**
```dart
// Before (problematic)
PopupMenuItem<double>(
  enabled: false,
  child: StatefulBuilder(
    builder: (context, setLocalState) {
      return Slider(value: playlistState.volume, ...);
    },
  ),
)

// After (correct)
PopupMenuItem<double>(
  enabled: false,
  child: Consumer(
    builder: (context, ref, _) {
      final volume = ref.watch(playlistProvider.select((s) => s.volume));
      return Slider(
        value: volume,
        onChanged: (v) => ref.read(playlistProvider.notifier).setVolume(v),
      );
    },
  ),
)
```

### 2.4 Add initialization failure cleanup (#5)
**File:** `biu_flutter/lib/features/player/presentation/providers/playlist_notifier.dart:80-86`

**Steps:**
1. Find `initialize()` method
2. Wrap initialization logic in try-catch
3. Call `_playerService.dispose()` in catch block before rethrowing

**Code Pattern:**
```dart
Future<void> initialize() async {
  try {
    await _playerService.init();
    // ... existing init logic
  } catch (e) {
    await _playerService.dispose();
    rethrow;
  }
}
```

### 2.5 Remove unused utility classes (#7)
**Files:**
- `biu_flutter/lib/core/utils/color_utils.dart`
- `biu_flutter/lib/core/utils/debouncer.dart`

**Steps:**
1. Verify `ColorUtils` has no usages: `grep -r "ColorUtils" biu_flutter/lib/`
2. Delete `color_utils.dart` entirely
3. Verify `Throttler` has no usages: `grep -r "Throttler" biu_flutter/lib/`
4. Remove only `Throttler` class from `debouncer.dart`, keep `Debouncer` if used

---

## 3. Low Priority: Auth Module

### 3.1 Remove country fallback list (#8)
**File:** `biu_flutter/lib/features/auth/presentation/widgets/sms_login_widget.dart:254-282`

**Steps:**
1. Find the hardcoded country list fallback (China, Hong Kong, Taiwan)
2. Remove the 3-country fallback, keep only default "86"
3. This aligns with source project which has no fallback

**Rationale:** Source project `biu/src/layout/navbar/login/code-login.tsx` only has default "86", no fallback countries.

### 3.2 Verify Geetest unavailable UI (#9)
**File:** `biu_flutter/lib/features/auth/presentation/widgets/geetest_dialog.dart:35-72`

**Steps:**
1. Check if desktop platform detection exists
2. Verify UI clearly shows "不可用" (unavailable) on Windows/Linux
3. If unclear, add clear messaging that password/SMS login requires mobile

**Note:** This is verification + potential UI text improvement, not a code fix.

---

## 4. Low Priority: Player Module

### 4.1 Fix URL refresh race condition (#10)
**File:** `biu_flutter/lib/features/player/presentation/providers/playlist_notifier.dart:624-688`

**Steps:**
1. Find URL validation and playback logic
2. Add check: if URL expired between validation and playback, refresh again
3. Consider using mutex or flag to prevent concurrent refreshes

**Pattern:**
```dart
Future<String> getValidUrl() async {
  var url = _cachedUrl;
  if (!isUrlValid(url)) {
    url = await _refreshUrl();
  }
  // Double-check after async operation
  if (!isUrlValid(url)) {
    throw Exception('Failed to get valid URL');
  }
  return url;
}
```

---

## 5. Low Priority: Favorites Module

### 5.1 Add platform parameter to API calls (#12)
**File:** `biu_flutter/lib/features/favorites/data/datasources/favorites_remote_datasource.dart`

**Steps:**
1. Find `collectFolder` method
2. Add `'platform': 'web'` to queryParameters
3. Find `uncollectFolder` method
4. Add `'platform': 'web'` to queryParameters

### 5.2 Extract duplicate dialog method (#13)
**File:** `biu_flutter/lib/features/favorites/presentation/screens/favorites_screen.dart`

**Steps:**
1. Find `_showCreateFolderDialog` in `FavoritesScreen`
2. Find duplicate in `_CreatedFoldersTab`
3. Extract to a shared utility function or widget
4. Options:
   - Move to `favorites_screen.dart` top level as private function
   - Create `create_folder_dialog.dart` widget

---

## 6. Low Priority: Search Module

### 6.1 Improve error display (#16)
**File:** `biu_flutter/lib/features/search/presentation/screens/search_screen.dart:411-425`

**Steps:**
1. Find error display widget
2. Replace raw exception string with user-friendly message
3. Pattern: `'搜索失败，请稍后重试'` instead of `error.toString()`

### 6.2 Remove unused SearchAllResult (#17)
**File:** `biu_flutter/lib/features/search/data/models/search_result.dart:238-293`

**Steps:**
1. Verify `SearchAllResult` has no usages
2. Delete the class and related code
3. Keep other result types that are used

### 6.3 Add tab loading state (#18)
**File:** `biu_flutter/lib/features/search/presentation/screens/search_screen.dart:112-126`

**Steps:**
1. Find tab switching logic
2. Add loading indicator during tab transition
3. Prevent flash of empty state

**Pattern:**
```dart
// When tab changes, show loading before data arrives
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

---

## 7. Low Priority: Home Module

### 7.1 Change English strings to Chinese (#20)
**File:** `biu_flutter/lib/features/home/presentation/screens/home_screen.dart`

**Steps:**
1. Find all English UI strings (e.g., "Hot Songs", "Music Artists")
2. Replace with Chinese equivalents from source project
3. Common replacements:
   - "Hot Songs" → "热门音乐"
   - "Music Artists" → "热门音乐人"
   - "Recommended" → "推荐"

### 7.2 Add refresh indicator feedback (#21)
**File:** `biu_flutter/lib/features/home/presentation/screens/home_screen.dart`

**Steps:**
1. Find RefreshIndicator or pull-to-refresh implementation
2. Ensure visual feedback during refresh
3. If missing, wrap content in RefreshIndicator

---

## 8. Low Priority: Artist Rank Module

### 8.1 Change English strings to Chinese (#22)
**File:** `biu_flutter/lib/features/artist_rank/presentation/screens/artist_rank_screen.dart`

**Steps:**
1. Find all English UI strings
2. Replace with Chinese from source project
3. Common replacements:
   - "Artist Rank" → "音乐人排行"
   - "Followers" → "粉丝"
   - "Songs" → "歌曲"

---

## 9. Low Priority: History & Later Modules

### 9.1 Fix code style in history (#23)
**File:** `biu_flutter/lib/features/history/presentation/providers/history_notifier.dart:35-37, 104-106`

**Steps:**
1. Find function calls with empty lines inside
2. Remove empty lines within function argument lists
3. Dart style guide: no blank lines inside function calls

**Example:**
```dart
// Before (wrong)
someFunction(
  arg1,

  arg2,
);

// After (correct)
someFunction(
  arg1,
  arg2,
);
```

### 9.2 Fix code style in later (#24)
**File:** `biu_flutter/lib/features/later/presentation/providers/later_notifier.dart:37-39, 112-114`

**Steps:** Same as 9.1 above

---

## 10. Low Priority: User Profile Module

### 10.1 Use route constants (#25)
**File:** `biu_flutter/lib/features/user_profile/presentation/widgets/video_series_tab.dart:198`

**Steps:**
1. Find hardcoded route string
2. Replace with `AppRoutes` constant
3. Ensure import of routes file

### 10.2 Add barrel export (#27)
**File:** `biu_flutter/lib/features/user_profile/user_profile.dart`

**Steps:**
1. Find or create barrel export file
2. Add `export 'presentation/widgets/user_favorites_tab.dart';`

---

## 11. Low Priority: Settings Module

### 11.1 Read version from package_info (#28)
**Files:**
- `biu_flutter/lib/features/settings/presentation/screens/settings_screen.dart:178`
- `biu_flutter/lib/features/settings/presentation/screens/about_screen.dart:11`

**Steps:**
1. Add package_info_plus dependency if not present
2. Create a version provider or use FutureBuilder
3. Replace hardcoded "1.0.0" with actual version

**Pattern:**
```dart
final packageInfo = await PackageInfo.fromPlatform();
final version = packageInfo.version;
```

---

## 12. Low Priority: Shared Playbar Module

### 12.1 Fix dynamic type (#29)
**File:** `biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:474`

**Steps:**
1. Find parameter with `dynamic` type
2. Replace with proper type annotation
3. Usually `Object?` or specific type

### 12.2 Fix mute button popup behavior (#30)
**File:** `biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:527-530`

**Steps:**
1. Find mute button in volume popup
2. Remove `Navigator.pop()` or popup close on mute
3. Allow user to adjust volume after muting

### 12.3 Update dependency documentation (#31)
**File:** `biu_flutter/lib/shared/widgets/playbar/full_player_screen.dart:6`

**Steps:**
1. Find NOTE comment about cross-layer dependencies
2. Add mention of favorites dependency
3. Document why these imports are acceptable

---

## 13. Low Priority: Core Network Module

### 13.1 Fix cookie domain consistency (#32)
**File:** `biu_flutter/lib/core/network/dio_client.dart:134`

**Steps:**
1. Find `getCookie` method
2. Change domain from `https://bilibili.com` to `.bilibili.com`
3. Ensure consistency with `setCookie` method

### 13.2 Improve platform check comment (#33)
**File:** `biu_flutter/lib/core/network/gaia_vgate_interceptor.dart:69-73`

**Steps:**
1. Find platform detection code
2. Add clearer comment explaining the check order
3. Document why specific order matters

### 13.3 Add null safety check in WBI (#34)
**File:** `biu_flutter/lib/core/network/wbi_sign.dart:77`

**Steps:**
1. Find WBI key extraction logic
2. Add defensive check for empty/null orig
3. Return meaningful default or throw clear error

---

## 14. Low Priority: Core Utils Module

### 14.1 Complete VideoFnval constants (#35)
**File:** `biu_flutter/lib/core/utils/constants.dart` (or create `video_constants.dart`)

**Steps:**
1. Find existing VideoFnval (has 2 values: dash=16, allDash=4048)
2. Add missing 7 constants from source project:
   - mp4 = 1
   - hdr = 64
   - fourK = 128
   - dolbyAudio = 256
   - dolbyVideo = 512
   - eightK = 1024
   - av1 = 2048

**Reference:** `biu/src/common/constants/video.ts`

### 14.2 Add VipType enum (#36)
**File:** `biu_flutter/lib/core/utils/constants.dart` (or create `vip_constants.dart`)

**Steps:**
1. Create VipType enum:
```dart
enum VipType {
  none(0),
  monthVip(1),
  yearVip(2);

  const VipType(this.value);
  final int value;
}
```
2. Find usages of `vipType >= 2` and replace with `vipType == VipType.yearVip.value`

**Reference:** `biu/src/common/constants/vip.ts`

---

## 15. Low Priority: Video/Audio Module

### 15.1 Fix AudioQuality documentation (#37)
**File:** `biu_flutter/lib/video/audio/data/datasources/audio_remote_datasource.dart:16-17`

**Steps:**
1. Find AudioQuality parameter comment
2. Update to match actual constant definitions
3. Ensure values align with API expectations

### 15.2 Return typed objects (#38)
**File:** `biu_flutter/lib/video/audio/data/datasources/audio_remote_datasource.dart:54-68`

**Steps:**
1. Find `getAudioInfo` method returning `Map<String, dynamic>`
2. Create `AudioStreamInfo` model class if not exists
3. Return typed object instead of raw Map

**Model:**
```dart
class AudioStreamInfo {
  final String url;
  final int quality;
  final String type;

  AudioStreamInfo({required this.url, required this.quality, required this.type});
}
```

---

## 16. Final Verification

### 16.1 Run full analysis
```bash
flutter analyze biu_flutter/
```

### 16.2 Build verification
```bash
flutter build apk --debug
```

### 16.3 Create commit
```bash
git add .
git commit -m "fix(multi): apply 32 audit fixes from module-internal-parity-audit

CRITICAL:
- Fix artist_rank Musician.uid type (String→int)

Medium:
- Add WBI signature to later API
- Implement hidden folder filtering in favorites
- Fix volume slider state in playbar popup
- Add player initialization cleanup
- Remove unused ColorUtils and Throttler

Low:
- Various code quality improvements across 14 modules
- Chinese string alignment with source project
- Dead code removal
- Type safety improvements
- Documentation updates

Closes #audit-fixes"
git push
```
