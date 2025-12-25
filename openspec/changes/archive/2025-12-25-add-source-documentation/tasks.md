# Implementation Tasks - Source Documentation

## Agent Instructions

This task list is designed for adding source documentation to Flutter public APIs. After completing each file:
1. Verify the source reference path is correct
2. Ensure code compiles: `flutter analyze`
3. Mark task as complete

**Documentation Format:**
```dart
/// Brief description.
///
/// Source: biu/src/path/to/file.ts#functionOrClassName
```

---

## Phase 1: Core Layer Documentation

### 1.1 Constants

- [x] 1.1.1 `lib/core/constants/response_code.dart`
  - Source: `biu/src/common/constants/response-code.ts`

- [x] 1.1.2 `lib/core/constants/audio.dart`
  - Source: `biu/src/common/constants/audio.tsx`

- [x] 1.1.3 `lib/core/constants/api.dart`
  - Source: Flutter-only (document as such)

- [x] 1.1.4 `lib/core/constants/app.dart`
  - Source: Flutter-only (document as such)

### 1.2 Utils

- [x] 1.2.1 `lib/core/utils/color_utils.dart`
  - Source: `biu/src/common/utils/color.ts`

- [x] 1.2.2 `lib/core/utils/number_utils.dart`
  - Source: `biu/src/common/utils/number.ts`

- [x] ~~1.2.3 `lib/core/utils/format_utils.dart`~~ **DELETED** - Duplicate of number_utils.dart

- [x] 1.2.4 `lib/core/utils/url_utils.dart`
  - Source: `biu/src/common/utils/url.ts` + `biu/src/common/utils/audio.ts#isUrlValid`

- [x] 1.2.5 `lib/core/utils/rsa_utils.dart`
  - Source: `biu/src/common/utils/cookie.ts` (RSA encryption part)

- [x] 1.2.6 `lib/core/utils/debouncer.dart`
  - Source: Flutter-only (document as such)

### 1.3 Extensions

- [x] 1.3.1 `lib/core/extensions/string_extensions.dart`
  - Source: `biu/src/common/utils/str.ts` + `biu/src/common/utils/url.ts`

- [x] 1.3.2 `lib/core/extensions/datetime_extensions.dart`
  - Source: `biu/src/common/utils/time.ts`

- [x] 1.3.3 `lib/core/extensions/duration_extensions.dart`
  - Source: `biu/src/common/utils/time.ts`

### 1.4 Errors

- [x] 1.4.1 `lib/core/errors/app_exception.dart`
  - Source: Flutter-only (document as such)

### 1.5 Network Layer

- [x] 1.5.1 `lib/core/network/dio_client.dart`
  - Source: `biu/src/service/request/index.ts`

- [x] 1.5.2 `lib/core/network/api/base_api_service.dart`
  - Source: Flutter-only (document as such)

- [x] 1.5.3 `lib/core/network/interceptors/auth_interceptor.dart`
  - Source: `biu/src/service/request/request-interceptors.ts`

- [x] 1.5.4 `lib/core/network/interceptors/response_interceptor.dart`
  - Source: `biu/src/service/request/response-interceptors.ts`

- [x] 1.5.5 `lib/core/network/interceptors/logging_interceptor.dart`
  - Source: `biu/src/service/request/response-interceptors.ts` (logging part)

- [x] 1.5.6 `lib/core/network/wbi/wbi_sign.dart`
  - Source: `biu/src/service/request/wbi-sign.ts`

- [x] 1.5.7 `lib/core/network/buvid/buvid_service.dart`
  - Source: `biu/src/service/web-buvid.ts`

- [x] 1.5.8 `lib/core/network/ticket/bili_ticket_service.dart`
  - Source: `biu/src/service/web-bili-ticket.ts`

### 1.6 Router

- [x] 1.6.1 `lib/core/router/routes.dart`
  - Source: `biu/src/routes.tsx`

- [x] 1.6.2 `lib/core/router/app_router.dart`
  - Source: `biu/src/app.tsx` + `biu/src/layout/index.tsx`

- [x] 1.6.3 `lib/core/router/auth_guard.dart`
  - Source: Flutter-only (document as such)

### 1.7 Storage

- [x] 1.7.1 `lib/core/storage/storage_service.dart`
  - Source: Flutter-only (Zustand persist -> SharedPreferences)

- [x] 1.7.2 `lib/core/storage/secure_storage_service.dart`
  - Source: Flutter-only (document as such)

---

## Phase 2: Feature Layer Documentation ✅ Completed

All feature module datasources and key components have been documented with source references:

- [x] Authentication datasources and providers
- [x] Favorites datasources and providers
- [x] Player services and providers
- [x] Search datasources and providers
- [x] History/Later/Follow datasources
- [x] User profile datasources
- [x] Playbar widgets

---

## Phase 3: Code Quality Issues (Discovered & Fixed)

### Fixed Issues

| File | Issue | Fix |
|------|-------|-----|
| `format_utils.dart` | Duplicate of number_utils.dart | **DELETED** |
| `number_utils.dart` | Wrong formatting for 1000-9999 | Fixed to match source behavior |
| `url_utils.dart` | Missing pageIndex support | Added optional parameter |
| `dio_client.dart` | Missing biliDio | Added biliDio getter |
| `playlist_notifier.dart` | addToNext didn't move existing items | Added move logic |
| `later_remote_datasource.dart` | Missing useCSRF for add/remove | Added CSRF option |
| `empty_state.dart` | Default message was "No content" | Changed to "暂无内容" |
| `cached_image.dart` | Inline `_formatUrl` duplicate | Use `UrlUtils.formatProtocol` |
| `track_list_item.dart` | Inline `_formatPlayCount` duplicate | Use `NumberUtils.formatCompact` |
| `track_list_item.dart` | Missing search highlight support | Added `highlightTitle` param |
| `track_list_item.dart` | Missing artist tap navigation | Added `artistMid` + `onArtistTap` |
| `video_card.dart` | Missing search highlight support | Added `highlightTitle` param |
| `video_card.dart` | Missing owner tap navigation | Added `ownerMid` + `onOwnerTap` |
| `search_result.dart` | Title stripped HTML in fromJson | Keep raw title, add `titlePlain` getter |
| - | New `highlighted_text.dart` | Parse `<em>` tags for search highlight |

### Settings Module Fixes (Phase 4)

| File | Issue | Fix |
|------|-------|-----|
| `app_settings.dart` | AudioQualitySetting values incorrect | Changed to `auto/lossless/high/medium/low` to match source |
| `settings_screen.dart` | Missing border radius setting | Added slider picker (0-24px) |
| `settings_screen.dart` | Missing background color settings | Added content background and background color pickers |
| `settings_notifier.dart` | Missing source references | Added source references |
| `color_picker.dart` | Missing source reference | Added source reference |
| `audio_quality_picker.dart` | Missing source reference | Added source reference |
| `about_screen.dart` | Missing Flutter-only marker | Added Flutter-only marker |
| `settings_notifier.dart` | Missing import/export functionality | Added exportSettings/importSettings methods |
| `settings_screen.dart` | Missing import/export UI | Added Data section with export/import buttons |

### Documented Simplifications

| Module | Missing Feature | Reason |
|--------|-----------------|--------|
| search | article/photo/live types | Music player doesn't need them |
| settings | System menu visibility (menu-settings.tsx) | Mobile uses bottom nav, no sidebar menus to hide |

---

## Phase 4: Shared Components Consistency Check

### New Components Added

| File | Source | Notes |
|------|--------|-------|
| `confirm_dialog.dart` | `confirm-modal/index.tsx` | Async loading, type colors (warning/danger) |
| `audio_visualizer.dart` | `audio-waveform/index.tsx` | Simulated animation (just_audio no FFT) |
| `loading_state.dart#VideoCardSkeleton` | `image-card/skeleton.tsx` | Card skeleton for grid loading |
| `loading_state.dart#VideoCardSkeletonGrid` | `grid-list/index.tsx` (loading) | Grid of card skeletons |

### Integration Changes

| File | Change |
|------|--------|
| `full_player_screen.dart` | Added `AudioVisualizer` in cover section |

### Verified Existing Implementations

| Source | Flutter Implementation | Status |
|--------|------------------------|--------|
| `search-filter/index.tsx` | `folder_detail_screen.dart` (inline) | ✅ Exists |
| `mv-action/index.tsx` | `video_card.dart#VideoCardAction` | ✅ Exists |

### Confirmed Flutter Native Alternatives

| Source | Flutter Alternative | Reason |
|--------|---------------------|--------|
| `ellipsis/index.tsx` | `Text.overflow` + `maxLines` | Mobile has no hover for tooltip |
| `grid-list/index.tsx` | `GridView.builder` + `AsyncValueWidget` | Native virtualization |
| `virtual-list/index.tsx` | `ListView.builder` | Native virtualization |
| `scroll-container/index.tsx` | Native scroll | Mobile doesn't need custom scrollbars |
| `if/index.tsx` | Conditional expressions | Dart syntax |

### Desktop-Only (Not Applicable)

- `shortcut-key-input/index.tsx` - Keyboard shortcuts
- `font-select/index.tsx` - Font selection
- `update-check-button/index.tsx` - Desktop auto-update
- `video-pages-download-select-modal/index.tsx` - Download selection

### Mobile Adaptation (Not Needed)

- `release-note-modal/index.tsx` - App store handles updates

---

## Breaking Changes Log

Document any changes that affect upper layers:

### Settings Module Changes
- `AudioQualitySetting` enum values changed: `standard` → `medium`, `hires` → `lossless`
- Added `fromValue()` migration for legacy values
- New dependencies: `file_picker`, `share_plus`

### Shared Widgets Changes
- New `ConfirmDialog` widget available for async confirmations
- New `AudioVisualizer` widget available for playback visualization
- New `VideoCardSkeleton` and `VideoCardSkeletonGrid` for loading states

---

## Phase 5: Video/Download + Layout/Routing Module Consistency Check ✅ Completed

### Video/Download Module Evaluation

| Source File | Status | Reason |
|-------------|--------|--------|
| `service/web-interface-view-detail.ts` | ➖ Not needed | Tags/Comments/Related are for video detail page, not music player |
| `service/web-interface-archive-desc.ts` | ➖ Not needed | Description already in view API response |
| `service/web-interface-ranking.ts` | ➖ Not needed | Video ranking, music uses music-hot-rank |
| `components/video-pages-download-select-modal/` | 🖥️ Desktop-only | Uses window.electron.addMediaDownloadTask |
| `store/modal/video-page-download-modal.ts` | 🖥️ Desktop-only | Pairs with download modal |

### Layout/Routing Module Evaluation

**Layout differences are valid mobile adaptations:**
- Desktop sidebar → Mobile bottom navigation
- Desktop top navbar → Mobile Profile page entries
- All menu functions verified accessible via routes

### Music Recommend Feature Implementation

**Discovery:** `/music-recommend` was missing from Flutter (功能缺失, not "移动端适配")

**Files Created:**
- `features/music_recommend/data/models/recommended_song.dart`
- `features/music_recommend/data/datasources/music_recommend_remote_datasource.dart`
- `features/music_recommend/presentation/providers/music_recommend_state.dart`
- `features/music_recommend/presentation/providers/music_recommend_notifier.dart`
- `features/music_recommend/presentation/screens/music_recommend_screen.dart`
- `features/music_recommend/presentation/widgets/recommended_song_card.dart`
- `features/music_recommend/music_recommend.dart`

**Files Modified:**
- `core/router/routes.dart` - Added musicRecommend route
- `core/router/app_router.dart` - Added route config and import
- `features/home/presentation/screens/home_screen.dart` - Added entry button

**Features:**
- API: `/x/centralization/interface/music/comprehensive/web/rank` with pagination
- Infinite scroll load more
- Pull-to-refresh
- Grid/List display modes
- Entry: HomeScreen "Music Recommend" button

### FILE_MAPPING.md Updates

- Updated Music/Artist Rank section: all 6 items now ✅ Full
- Updated Video/Download section: clarified desktop-only and not-needed items
- Updated Layout/Routing section: documented mobile adaptations with menu coverage
- Updated Missing Features section: removed implemented items
- Updated File Mapping Summary table

---

## Phase 6: User Profile/Follow + Remaining Features Consistency Check ✅ Completed

### User Profile/Follow Module Evaluation

| Source File | Status | Reason |
|-------------|--------|--------|
| `service/space-setting.ts` | ✅ Implemented | Privacy settings for favorites tab visibility |
| `service/space-navnum.ts` | ➖ Not needed | Nav badge counts not used in mobile music player UI |
| `service/space-masterpiece.ts` | ➖ Not needed | B站特有功能，网易云/QQ音乐都没有代表作功能 |
| `service/space-top-arc.ts` | ➖ Not needed | B站特有功能，置顶视频不适用于音乐播放器 |
| `service/space-seasons-series-list.ts` | ➖ Not needed | B站特有功能，视频合集不适用于音乐播放器 |
| `service/web-dynamic.ts` | ➖ Not needed | Source code only filters video dynamics, overlaps with video posts |
| `service/web-dynamic-feed-thumb.ts` | ➖ Not needed | Depends on dynamic feature |
| `pages/user-profile/favorites.tsx` | ✅ Implemented | User's public folders grid |
| `pages/user-profile/video-series.tsx` | ➖ Not needed | B站特有功能 |
| `pages/user-profile/dynamic-list/` | ➖ Not needed | Overlaps with video posts |
| `components/dynamic-feed/` | ➖ Not needed | Overlaps with video posts |

### Remaining Missing Features Evaluation

| Feature | Status | Reason |
|---------|--------|--------|
| Video Page List UI | ✅ Implemented | `_VideoPageListSheet` in full_player_screen.dart |
| Volume Slider | ✅ Implemented | `_buildVolumeControl` with popup vertical slider |
| Quick Favorite | ✅ Implemented | `_showFavoriteSheet` in full_player_screen.dart AppBar |
| Video Series Support | ➖ Not needed | B站特有功能 |
| Dynamic Feed | ➖ Not needed | Overlaps with video posts |
| User Masterpiece/Top Videos | ➖ Not needed | B站特有功能 |
| Gaia VGate Verification | ✅ Implemented | See Phase 7 |
| Download Feature | 🖥️ Desktop-only | Requires FFmpeg |

### Files Created

| File | Source | Notes |
|------|--------|-------|
| `data/models/space_setting.dart` | `service/space-setting.ts` | Privacy settings model |
| `widgets/user_favorites_tab.dart` | `pages/user-profile/favorites.tsx` | User folders grid with navigation |

### Files Modified

| File | Change |
|------|--------|
| `user_profile_remote_datasource.dart` | Added `getSpaceSetting` API method |
| `user_profile_state.dart` | Added `spacePrivacy`, `userFolders` fields and loading states |
| `user_profile_notifier.dart` | Added `loadUserFolders`, `loadMoreFolders` methods + favorites datasource |
| `user_profile_screen.dart` | Dynamic tabs (Videos, Favorites) based on privacy settings |
| `full_player_screen.dart` | Added volume slider popup, quick favorite button, video page list sheet |

### Player Module Enhancements

**Volume Slider** (`full_player_screen.dart:388-462`):
- Vertical slider in popup menu
- Volume percentage display
- Mute button at bottom

**Quick Favorite** (`full_player_screen.dart:89-125`):
- Star button in AppBar
- Opens FolderSelectSheet
- Supports both MV and audio types

**Video Page List** (`full_player_screen.dart:703-863`):
- List button in AppBar (only shown for multi-part videos)
- Shows current part tooltip
- Search filter for parts
- Tap to switch parts

### FILE_MAPPING.md Updates

- Updated User Profile/Follow section: 15 fully mapped, 9 not needed (with reasons)
- Updated Player Module section: volume, quick-favorite, video-page-list now ✅
- Updated Missing Features section: reorganized with "Not Needed" table
- Updated File Mapping Summary: Player 20/20, User Profile 15/24 mapped

---

## Phase 7: Final Consistency Audit + Gaia VGate Implementation ✅ Completed

### Gaia VGate Verification Implementation

**Background:** When Bilibili API returns `v_voucher` in response data, it indicates risk control has been triggered. The app needs to handle this by showing a captcha verification dialog.

**Source Files:**
- `biu/src/service/gaia-vgate.ts` - Response type definitions
- `biu/src/service/gaia-vgate-register.ts` - Register for captcha
- `biu/src/service/gaia-vgate-validate.ts` - Validate captcha result
- `biu/src/service/request/response-interceptors.ts#geetestInterceptors` - Auto-handling

### Files Created

| File | Source | Notes |
|------|--------|-------|
| `data/models/gaia_vgate_response.dart` | `gaia-vgate*.ts` | Register/Validate response models |
| `interceptors/gaia_vgate_interceptor.dart` | `response-interceptors.ts#geetestInterceptors` | Auto-detect v_voucher, show dialog, retry |
| `router/navigator_key.dart` | Flutter-only | Global context holder for interceptors |

### Files Modified

| File | Change |
|------|--------|
| `auth_remote_datasource.dart` | Added `registerGaiaVgate`, `validateGaiaVgate` methods |
| `dio_client.dart` | Added `GaiaVgateInterceptor`, updated `setCookie` with domain param |
| `main.dart` | Set global context via MaterialApp builder |

### Implementation Flow

1. **Detection:** `GaiaVgateInterceptor.onResponse` checks for `v_voucher` in response data
2. **Register:** Call `/x/gaia-vgate/v1/register` to get Geetest parameters
3. **Dialog:** Show `GeetestDialog` with WebView-based captcha (Android/iOS)
4. **Validate:** Call `/x/gaia-vgate/v1/validate` to get `grisk_id` (gaia_vtoken)
5. **Retry:** Store token in cookie, retry original request with `gaia_vtoken` param

### Missing Items Final Evaluation

| Source File | Status | Reason |
|-------------|--------|--------|
| `audio-song-info.ts` | ➖ Not needed | Audio info comes from favorites API response |
| `audio-rank.ts` | ➖ Not needed | Dead code in source (defined but never imported) |
| `video.ts` (constants) | ➖ Not needed | Video quality for streaming, not audio playback |
| `collection.ts` (constants) | ➖ Not needed | Video series type, B站特有 |
| `feed.ts` (constants) | ➖ Not needed | Dynamic feed feature not needed |
| `vip.ts` (constants) | ➖ Not needed | VIP type inline in user models |
| `json.ts` (utils) | ➖ Not needed | Dart has built-in JSON handling |
| `fav.ts` (utils) | ✅ Exists | `isPrivate` inline in `FavoritesFolder.isPrivate` |
| `member-web-account.ts` | ➖ Not needed | Dead code (defined but never used) |
| `user-account.ts` | ➖ Not needed | Used for video series (B站特有) |
| `fav-resource-infos.ts` | ➖ Not needed | Dead code |
| `fav-season-*.ts` | ➖ Not needed | Video series collecting, B站特有 |
| `fav-video-favoured.ts` | ➖ Not needed | Dead code |

### FILE_MAPPING.md Final Updates

- All ❌ Missing items resolved (implemented or evaluated as not needed)
- Updated File Mapping Summary: ~69% fully mapped, ~7% mobile adapted, ~24% desktop-only/not needed
- Auth section: gaia-vgate now ✅, member-web-account/user-account marked ➖
- Player section: audio-song-info/audio-rank marked ➖
- Constants section: relation.ts now ✅ (mapped to UserRelation), menus.tsx now ✅ (covered by routes)
- Utils section: fav.ts now ✅ (inline), geetest.ts now ✅ (geetest_dialog.dart)
- Final Status: No remaining ❌ Missing items
