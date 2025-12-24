# Biu Project File Mapping Document
# Electron -> Flutter Migration File Mapping

This document provides a comprehensive mapping between the source project (Electron/React) and the target project (Flutter), including layer hierarchy analysis, file mappings, and boundary inconsistencies.

---

## Table of Contents

1. [Layer Hierarchy Comparison](#layer-hierarchy-comparison)
2. [File Mapping Summary](#file-mapping-summary)
3. [Detailed File Mappings by Module](#detailed-file-mappings-by-module)
4. [Boundary Inconsistencies](#boundary-inconsistencies)
5. [Missing Features](#missing-features)

---

## Layer Hierarchy Comparison

### Source Project (Electron) Hierarchy

```
biu/src/
├── app.tsx, index.tsx, routes.tsx    # Entry Layer
├── common/
│   ├── constants/                     # Constants Layer
│   ├── utils/                         # Utilities Layer
│   └── hooks/                         # Hooks Layer
├── components/                        # Shared Components Layer
├── layout/
│   ├── navbar/                        # Navigation Layout
│   ├── playbar/                       # Playbar Layout
│   └── side/                          # Sidebar Layout
├── pages/                             # Pages Layer
├── service/                           # API Service Layer
├── store/                             # State Management Layer (Zustand)
└── types/                             # TypeScript Types Layer
```

### Target Project (Flutter) Hierarchy

```
biu_flutter/lib/
├── main.dart                          # Entry Layer
├── core/
│   ├── constants/                     # Constants Layer
│   ├── errors/                        # Error Handling Layer (NEW)
│   ├── extensions/                    # Extensions Layer (NEW)
│   ├── network/                       # Network Layer
│   │   ├── api/                       # API Base Classes
│   │   ├── buvid/                     # BUVID Service
│   │   ├── interceptors/              # Request/Response Interceptors
│   │   ├── ticket/                    # Ticket Service
│   │   └── wbi/                       # WBI Sign Service
│   ├── router/                        # Router Layer
│   ├── storage/                       # Storage Layer (NEW)
│   └── utils/                         # Utilities Layer
├── features/                          # Feature Modules (Clean Architecture)
│   └── [feature]/
│       ├── data/
│       │   ├── datasources/           # Remote/Local Data Sources
│       │   ├── models/                # Data Transfer Objects
│       │   └── repositories/          # Repository Implementations
│       ├── domain/
│       │   ├── entities/              # Domain Entities
│       │   └── repositories/          # Repository Interfaces
│       └── presentation/
│           ├── providers/             # State Management (Riverpod)
│           ├── screens/               # Page Screens
│           └── widgets/               # Feature-specific Widgets
└── shared/
    ├── layout/                        # Shared Layout (empty)
    ├── theme/                         # Theme Configuration
    └── widgets/                       # Shared Widgets
```

### Key Architectural Differences

| Aspect | Electron | Flutter |
|--------|----------|---------|
| Architecture | Flat MVC-style | Clean Architecture per feature |
| State Management | Zustand (single store) | Riverpod (StateNotifier) |
| API Services | One file per endpoint | Consolidated DataSource classes |
| Components | Shared components folder | Split between shared/widgets and feature/widgets |
| Layout | Desktop: Sidebar + Navbar + Playbar | Mobile: BottomNav + MiniPlaybar |
| Routing | React Router (flat) | GoRouter (shell routes) |

---

## File Mapping Summary

| Category | Total Source Files | Fully Mapped | Mobile Adapted | Desktop-only/Not needed |
|----------|-------------------|--------------|----------------|-------------------------|
| Constants | 7 | 2 | 0 | 5 |
| Utils/Hooks | 13 | 2 | 4 | 7 |
| Network/Service | 6 | 6 | 0 | 0 |
| Auth | 17 | 14 | 0 | 3 |
| Favorites | 18 | 14 | 0 | 4 |
| Player | 20 | 20 | 0 | 0 |
| Search/History/Later | 12 | 12 | 0 | 0 |
| User Profile/Follow | 24 | 15 | 0 | 9 |
| Music/Artist Rank | 6 | 6 | 0 | 0 |
| Settings | 7 | 6 | 1 | 0 |
| Shared Components | 26 | 12 | 6 | 8 |
| Layout | 10 | 4 | 5 | 1 |
| Video/Download | 9 | 1 | 0 | 8 |
| **Total** | **175** | **114** | **16** | **45** |

**Overall Migration Rate: ~65% fully mapped, ~9% mobile adapted, ~26% desktop-only or not needed**

*Note: "Mobile Adapted" includes Flutter native alternatives and mobile UI adaptations.*

---

## Detailed File Mappings by Module

### 1. Core / Constants & Utils

#### Constants

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `common/constants/response-code.ts` | `core/constants/response_code.dart` | ✅ Full |
| `common/constants/audio.tsx` | `core/constants/audio.dart` | ✅ Full |
| `common/constants/video.ts` | - | ❌ Missing |
| `common/constants/collection.ts` | - | ❌ Missing |
| `common/constants/feed.ts` | - | ❌ Missing |
| `common/constants/relation.ts` | - | ❌ Missing |
| `common/constants/vip.ts` | - | ❌ Missing |
| `common/constants/menus.tsx` | - | ❌ Missing |
| - | `core/constants/api.dart` | 🆕 Flutter-only |
| - | `core/constants/app.dart` | 🆕 Flutter-only |

#### Utils

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `common/utils/color.ts` | `core/utils/color_utils.dart` | ✅ Full | Flutter has more features |
| `common/utils/number.ts` | `core/utils/number_utils.dart` | ✅ Full | Deleted duplicate format_utils.dart |
| `common/utils/url.ts` | `core/utils/url_utils.dart` + `core/extensions/string_extensions.dart` | ⚠️ One-to-Many | Partial overlap |
| `common/utils/time.ts` | `core/extensions/datetime_extensions.dart` + `duration_extensions.dart` | ⚠️ One-to-Many | Uses extensions pattern |
| `common/utils/str.ts` | `core/extensions/string_extensions.dart` | ✅ Full | stripHtml function |
| `common/utils/audio.ts` | `core/utils/url_utils.dart` (partial) | ⚠️ Partial | Only isUrlValid migrated |
| `common/utils/cookie.ts` | `core/utils/rsa_utils.dart` (partial) | ⚠️ Partial | Only RSA encryption |
| `common/utils/json.ts` | - | ❌ Missing | Dart has built-in handling |
| `common/utils/fav.ts` | - | ❌ Missing |
| `common/utils/geetest.ts` | - | ❌ Missing | Platform-specific |
| `common/utils/shortcut.ts` | - | ❌ Missing | Desktop-specific |
| `common/utils/mini-player.ts` | - | ❌ Missing | Desktop-specific |
| `common/hooks/use-geetest.ts` | - | ❌ Missing | React hook |
| - | `core/utils/debouncer.dart` | 🆕 Flutter-only |
| - | `core/errors/app_exception.dart` | 🆕 Flutter-only |

---

### 2. Network Layer

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `service/request/index.ts` | `core/network/dio_client.dart` | ✅ Full | Axios → Dio |
| `service/request/request-interceptors.ts` | `core/network/interceptors/auth_interceptor.dart` | ✅ Full | Missing: cookie refresh check |
| `service/request/response-interceptors.ts` | `core/network/interceptors/response_interceptor.dart` + `logging_interceptor.dart` | ⚠️ One-to-Many | Missing: Geetest auto-handling |
| `service/request/wbi-sign.ts` | `core/network/wbi/wbi_sign.dart` | ✅ Full | |
| `service/web-buvid.ts` | `core/network/buvid/buvid_service.dart` | ✅ Full | Flutter has local generation fallback |
| `service/web-bili-ticket.ts` | `core/network/ticket/bili_ticket_service.dart` | ✅ Full | |
| - | `core/network/api/base_api_service.dart` | 🆕 Flutter-only |

---

### 3. Auth Module

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/passport-login-web-qrcode-generate.ts` | `features/auth/data/datasources/auth_remote_datasource.dart` | ✅ |
| `service/passport-login-web-qrcode-poll.ts` | ↳ (same file, pollQrCodeStatus) | ✅ |
| `service/passport-login-web-key.ts` | ↳ (same file, getWebKey) | ✅ |
| `service/passport-login-web-login-passport.ts` | ↳ (same file, loginWithPassword) | ✅ |
| `service/passport-login-web-sms-send.ts` | ↳ (same file, sendSmsCode) | ✅ |
| `service/passport-login-web-login-sms.ts` | ↳ (same file, loginWithSms) | ✅ |
| `service/passport-login-captcha.ts` | ↳ (same file, getCaptcha) | ✅ |
| `service/passport-login-exit.ts` | ↳ (same file, logout) | ✅ |
| `service/passport-login-web-cookie-info.ts` | ↳ (same file, getCookieInfo) | ✅ |
| `service/passport-login-web-cookie-refresh.ts` | ↳ + `data/services/cookie_refresh_service.dart` | ✅ |
| `service/passport-login-web-confirm-refresh.ts` | ↳ (same file, confirmRefresh) | ✅ |
| `service/user-info.ts` | ↳ (same file, getUserInfo) | ✅ |
| `service/passport-login-web-country.ts` | ↳ (same file, getCountryList) | ✅ |
| `service/gaia-vgate*.ts` (3 files) | - | ❌ Missing |
| `service/member-web-account.ts` | - | ❌ Missing |
| `service/user-account.ts` | - | ❌ Missing |
| `store/token.ts` | `features/auth/domain/entities/auth_token.dart` | ✅ |
| `store/user.ts` | `features/auth/presentation/providers/auth_notifier.dart` | ✅ |
| `common/hooks/use-geetest.ts` | `features/auth/presentation/providers/geetest_notifier.dart` | ✅ |
| `layout/navbar/login/index.tsx` | `features/auth/presentation/screens/login_screen.dart` | ✅ |
| `layout/navbar/login/qrcode-login.tsx` | `features/auth/presentation/widgets/qr_login_widget.dart` | ✅ |
| `layout/navbar/login/password-login.tsx` | `features/auth/presentation/widgets/password_login_widget.dart` | ✅ |
| `layout/navbar/login/code-login.tsx` | `features/auth/presentation/widgets/sms_login_widget.dart` | ✅ |

**Models:**
- `features/auth/data/models/captcha_response.dart`
- `features/auth/data/models/login_response.dart`
- `features/auth/data/models/qrcode_response.dart`
- `features/auth/data/models/session_response.dart`
- `features/auth/data/models/user_info_response.dart`
- `features/auth/domain/entities/user.dart`

---

### 4. Favorites Module

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/fav-folder-add.ts` | `features/favorites/data/datasources/favorites_remote_datasource.dart` (createFolder) | ✅ |
| `service/fav-folder-created-list.ts` | ↳ (getCreatedFolders) | ✅ |
| `service/fav-folder-created-list-all.ts` | ↳ (getAllCreatedFolders) | ✅ |
| `service/fav-folder-collected-list.ts` | ↳ (getCollectedFolders) | ✅ |
| `service/fav-folder-info.ts` | ↳ (getFolderInfo) | ✅ |
| `service/fav-folder-edit.ts` | ↳ (editFolder) | ✅ |
| `service/fav-folder-del.ts` | ↳ (deleteFolders) | ✅ |
| `service/fav-folder-fav.ts` | ↳ (collectFolder) | ✅ |
| `service/fav-folder-unfav.ts` | ↳ (uncollectFolder) | ✅ |
| `service/fav-folder-deal.ts` | ↳ (dealResource) | ✅ |
| `service/fav-resource.ts` | ↳ (getFolderResources) | ✅ |
| `service/fav-resource-batch-del.ts` | ↳ (batchDeleteResources) | ✅ |
| `service/fav-resource-copy.ts` | ↳ (batchCopyResources) | ✅ |
| `service/fav-resource-move.ts` | ↳ (batchMoveResources) | ✅ |
| `service/fav-resource-clean.ts` | ↳ (cleanInvalidResources) | ✅ |
| `service/fav-resource-infos.ts` | - | ❌ Missing |
| `service/fav-season-fav.ts` | - | ❌ Missing |
| `service/fav-season-unfav.ts` | - | ❌ Missing |
| `service/fav-video-favoured.ts` | - | ❌ Missing |
| `components/favorites-edit-modal/index.tsx` | `features/favorites/presentation/widgets/folder_edit_dialog.dart` | ✅ |
| `components/favorites-select-modal/index.tsx` | `features/favorites/presentation/widgets/folder_select_sheet.dart` | ✅ |
| `pages/video-collection/index.tsx` | `features/favorites/presentation/screens/favorites_screen.dart` | ✅ |
| `pages/video-collection/favorites.tsx` | `features/favorites/presentation/screens/folder_detail_screen.dart` | ✅ |
| `pages/video-collection/video-series.tsx` | - | ❌ Missing |
| `layout/side/collection/index.tsx` | - | ❌ Mobile nav different |

---

### 5. Player Module

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `store/play-list.ts` | `features/player/presentation/providers/playlist_notifier.dart` + `playlist_state.dart` | ✅ | |
| `store/play-progress.ts` | (integrated into playlist_notifier.dart) | ✅ | |
| `service/player-playurl.ts` | `features/video/data/datasources/video_remote_datasource.dart` | ✅ | |
| `service/player-pagelist.ts` | (integrated into video_remote_datasource.dart) | ✅ | |
| `service/audio-web-url.ts` | `features/audio/data/datasources/audio_remote_datasource.dart` | ✅ | |
| `service/audio-song-info.ts` | - | ❌ Missing | |
| `service/audio-rank.ts` | - | ❌ Missing | |
| `layout/playbar/index.tsx` | `shared/widgets/playbar/playbar.dart` (barrel) | ✅ | |
| `layout/playbar/left/index.tsx` | `shared/widgets/playbar/mini_playbar.dart` | ✅ | |
| `layout/playbar/center/index.tsx` | ↳ + `full_player_screen.dart` | ✅ | |
| `layout/playbar/center/progress.tsx` | ↳ (integrated) | ✅ | |
| `layout/playbar/right/index.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ | |
| `layout/playbar/right/play-mode.tsx` | ↳ (integrated) | ✅ | |
| `layout/playbar/right/rate.tsx` | ↳ (_RateDialog) | ✅ | |
| `layout/playbar/right/volume.tsx` | ↳ (_buildVolumeControl with popup slider) | ✅ | Vertical slider popup with mute button |
| `layout/playbar/right/play-list-drawer/` | ↳ (_PlaylistSheet) | ✅ | |
| `layout/playbar/right/download.tsx` | - | 🖥️ Desktop-only | Requires FFmpeg |
| `layout/playbar/right/mv-fav-folder-select.tsx` | ↳ (_showFavoriteSheet) | ✅ | Quick add-to-favorites in AppBar |
| `layout/playbar/left/video-page-list/` | ↳ (_VideoPageListSheet) | ✅ | Multi-part video switcher with search |
| `pages/mini-player/*` | - | 🖥️ Desktop-only | |
| - | `shared/widgets/playbar/full_player_screen.dart` | 🆕 Flutter-only | |

**Domain/Data:**
- `features/player/domain/entities/play_item.dart`
- `features/player/services/audio_player_service.dart`
- `features/player/services/audio_service_init.dart`
- `features/audio/data/models/audio_stream.dart`

---

### 6. Search / History / Later Modules

#### Search

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/main-suggest.ts` | `features/search/data/datasources/search_remote_datasource.dart` | ✅ |
| `service/web-interface-search-all.ts` | ↳ (searchAll) | ✅ |
| `service/web-interface-search-type.ts` | ↳ (searchVideo, searchUser) | ✅ |
| `store/search-history.ts` | `features/search/presentation/providers/search_history_notifier.dart` | ✅ |
| `pages/search/index.tsx` | `features/search/presentation/screens/search_screen.dart` | ✅ |
| `pages/search/search-type.tsx` | (integrated into search_screen.dart) | ✅ |
| `pages/search/video-list.tsx` | (integrated into search_screen.dart) | ✅ |
| `pages/search/user-list.tsx` | `features/search/presentation/widgets/user_search_card.dart` | ✅ |
| `layout/navbar/search/index.tsx` | `features/search/presentation/widgets/search_history_widget.dart` | ✅ |

#### History

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/web-interface-history-cursor.ts` | `features/history/data/datasources/history_remote_datasource.dart` | ✅ |
| `pages/history/index.tsx` | `features/history/presentation/screens/history_screen.dart` | ✅ |

#### Later (Watch Later)

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/history-toview-list.ts` | `features/later/data/datasources/later_remote_datasource.dart` | ✅ |
| `service/history-toview-add.ts` | ↳ (addToWatchLater) | ✅ |
| `service/history-toview-del.ts` | ↳ (removeFromWatchLater) | ✅ |
| `service/history-toview-clear.ts` | ↳ (clearWatchedFromWatchLater) | ✅ |
| `pages/later/index.tsx` | `features/later/presentation/screens/later_screen.dart` | ✅ |
| `pages/later/action.tsx` | `features/later/presentation/widgets/later_item_card.dart` | ✅ |

---

### 7. User Profile / Follow Modules

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `service/space-wbi-acc-info.ts` | `features/user_profile/data/datasources/user_profile_remote_datasource.dart` | ✅ | |
| `service/space-wbi-acc-relation.ts` | ↳ (getSpaceRelation) | ✅ | |
| `service/space-wbi-arc-search.ts` | ↳ (getSpaceVideos) | ✅ | |
| `service/relation-stat.ts` | ↳ (getRelationStat) | ✅ | |
| `service/space-setting.ts` | ↳ (getSpaceSetting) + `data/models/space_setting.dart` | ✅ | Privacy settings for favorites tab visibility |
| `service/space-navnum.ts` | - | ➖ Not needed | Nav badge counts, not used in mobile music player |
| `service/space-masterpiece.ts` | - | ➖ Not needed | B站特有功能，网易云/QQ音乐都没有 |
| `service/space-top-arc.ts` | - | ➖ Not needed | B站特有功能，网易云/QQ音乐都没有 |
| `service/space-seasons-series-list.ts` | - | ➖ Not needed | B站特有功能，视频合集不适用于音乐播放器 |
| `service/relation-followings.ts` | `features/follow/data/datasources/follow_remote_datasource.dart` | ✅ | |
| `service/relation-modify.ts` | ↳ (modifyRelation, followUser, unfollowUser) | ✅ | |
| `service/web-dynamic.ts` | - | ➖ Not needed | Source code only filters video dynamics, overlaps with video posts |
| `service/web-dynamic-feed-thumb.ts` | - | ➖ Not needed | Depends on dynamic feature |
| `pages/user-profile/index.tsx` | `features/user_profile/presentation/screens/user_profile_screen.dart` | ✅ | With tabs (Videos, Favorites) |
| `pages/user-profile/space-info.tsx` | `features/user_profile/presentation/widgets/space_info_header.dart` | ✅ | |
| `pages/user-profile/video-post.tsx` | `features/user_profile/presentation/widgets/video_post_card.dart` | ✅ | |
| `pages/user-profile/favorites.tsx` | `features/user_profile/presentation/widgets/user_favorites_tab.dart` | ✅ | User's public folders grid |
| `pages/user-profile/video-series.tsx` | - | ➖ Not needed | B站特有功能 |
| `pages/user-profile/dynamic-list/` | - | ➖ Not needed | Overlaps with video posts |
| `pages/follow-list/index.tsx` | `features/follow/presentation/screens/follow_list_screen.dart` | ✅ | |
| `pages/follow-list/user-card.tsx` | `features/follow/presentation/widgets/following_card.dart` | ✅ | |
| `components/dynamic-feed/` | - | ➖ Not needed | Overlaps with video posts |

---

### 8. Music/Artist Rank Modules

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/music-hot-rank.ts` | `features/music_rank/data/datasources/music_rank_remote_datasource.dart` | ✅ |
| `pages/music-rank/index.tsx` | `features/home/presentation/screens/home_screen.dart` | ✅ Full |
| `service/music-comprehensive-web-rank.ts` | `features/music_recommend/data/datasources/music_recommend_remote_datasource.dart` | ✅ Full |
| `pages/music-recommend/index.tsx` | `features/music_recommend/presentation/screens/music_recommend_screen.dart` | ✅ Full |
| `service/musician-list.ts` | `features/artist_rank/data/datasources/artist_rank_remote_datasource.dart` | ✅ |
| `pages/artist-rank/index.tsx` | `features/artist_rank/presentation/screens/artist_rank_screen.dart` | ✅ |

---

### 9. Settings Module

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `store/settings.ts` | `features/settings/presentation/providers/settings_notifier.dart` | ✅ Full |
| `pages/settings/index.tsx` | `features/settings/presentation/screens/settings_screen.dart` | ✅ Full |
| `pages/settings/system-settings.tsx` | (integrated into settings_screen.dart) | ✅ Full |
| `pages/settings/menu-settings.tsx` | (simplified: hidden folders only in settings_screen.dart) | ⚠️ Simplified |
| `pages/settings/export-import.tsx` | `features/settings/presentation/providers/settings_notifier.dart` | ✅ Full |
| `pages/settings/shortcut-settings.tsx` | - | ❌ Desktop-only |
| `store/shortcuts.ts` | - | ❌ Desktop-only |
| `shared/settings/app-settings.ts` | `features/settings/domain/entities/app_settings.dart` | ✅ Full |
| `components/color-picker/` | `features/settings/presentation/widgets/color_picker.dart` | ✅ Full |
| - | `features/settings/presentation/screens/about_screen.dart` | 🆕 Flutter-only |
| - | `features/settings/presentation/widgets/audio_quality_picker.dart` | 🆕 Flutter-only |

---

### 10. Shared Components

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `components/empty/index.tsx` | `shared/widgets/empty_state.dart` | ✅ | |
| `components/error-fallback/index.tsx` | `shared/widgets/error_state.dart` | ✅ | |
| `components/image/index.tsx` | `shared/widgets/cached_image.dart` | ✅ | |
| `components/music-list-item/index.tsx` | `shared/widgets/track_list_item.dart` | ✅ | highlightTitle + onArtistTap |
| `components/mv-card/index.tsx` | `shared/widgets/video_card.dart` | ✅ | highlightTitle + onOwnerTap + VideoCardAction |
| `components/image-card/index.tsx` | `shared/widgets/video_card.dart` | ✅ | |
| `components/music-list-item/index.tsx#isTitleIncludeHtmlTag` | `shared/widgets/highlighted_text.dart` | ✅ | |
| `components/image-card/skeleton.tsx` | `shared/widgets/loading_state.dart#VideoCardSkeleton` | ✅ | VideoCardSkeleton + VideoCardSkeletonGrid |
| `components/confirm-modal/index.tsx` | `shared/widgets/confirm_dialog.dart` | ✅ | Async loading, type colors |
| `components/mv-action/index.tsx` | `shared/widgets/video_card.dart#VideoCardAction` | ✅ | Download is Desktop-only |
| `components/async-button/index.tsx` | Flutter different pattern | 🔵 | Riverpod state management |
| `components/audio-waveform/index.tsx` | `shared/widgets/audio_visualizer.dart` | ✅ | Simulated (just_audio no FFT) |
| `components/ellipsis/index.tsx` | Flutter native | 🔵 | Text.overflow + maxLines |
| `components/grid-list/index.tsx` | Flutter native | 🔵 | GridView.builder + AsyncValueWidget |
| `components/if/index.tsx` | Flutter native | 🔵 | Conditional expressions |
| `components/menu/` | - | ➖ | Directory not found |
| `components/scroll-container/index.tsx` | Flutter native | 🔵 | Mobile: native scroll |
| `components/search-filter/index.tsx` | `features/favorites/.../folder_detail_screen.dart` | ✅ | Inline in folder detail |
| `components/select-all-checkbox-group/index.tsx` | - | ➖ | Settings simplified |
| `components/shortcut-key-input/index.tsx` | - | 🖥️ | Desktop-only |
| `components/typography/index.tsx` | - | ➖ | Used by release-note-modal |
| `components/update-check-button/index.tsx` | - | 🖥️ | Desktop-only |
| `components/video-pages-download-select-modal/index.tsx` | - | 🖥️ | Desktop-only |
| `components/virtual-list/index.tsx` | Flutter native | 🔵 | ListView.builder is virtualized |
| `components/release-note-modal/index.tsx` | - | 📱 | Mobile: app store updates |
| `components/font-select/index.tsx` | - | 🖥️ | Desktop-only |
| `components/theme/index.tsx` | `shared/theme/app_theme.dart` | ✅ | |
| - | `shared/widgets/async_value_widget.dart` | 🆕 | Flutter-only |
| - | `shared/widgets/loading_state.dart` | 🆕 | Flutter-only (shimmer, skeleton) |

**Legend:**
- ✅ Implemented
- 🔵 Flutter native alternative
- 📱 Mobile adaptation (not needed)
- 🖥️ Desktop-only (not applicable)
- ⚠️ Future enhancement
- ➖ Not needed
- 🆕 Flutter-only

---

### 11. Video / Download

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `service/web-interface-view.ts` | `features/video/data/datasources/video_remote_datasource.dart` | ✅ | |
| `service/web-interface-view-detail.ts` | - | ➖ Not needed | Tags/Comments/Related are for video detail page, not needed for music player |
| `service/web-interface-archive-desc.ts` | - | ➖ Not needed | Description already in view API response |
| `service/web-interface-ranking.ts` | - | ➖ Not needed | Video ranking, not music ranking. Music uses music-hot-rank |
| `pages/download-list/` | - | 🖥️ Desktop-only | Requires FFmpeg and file system access |
| `components/video-pages-download-select-modal/` | - | 🖥️ Desktop-only | Uses window.electron.addMediaDownloadTask |
| `store/modal/video-page-download-modal.ts` | - | 🖥️ Desktop-only | Pairs with download modal |
| `shared/types/download.d.ts` | - | 🖥️ Desktop-only | Download types |
| `electron/ipc/download/` | - | 🖥️ Desktop-only | Electron IPC |

---

### 12. Layout / Routing

| Electron Source | Flutter Target | Status | Notes |
|-----------------|----------------|--------|-------|
| `layout/index.tsx` | `core/router/app_router.dart` (MainShell) | 📱 Mobile adaptation | Desktop: Sidebar+Navbar+Playbar → Mobile: BottomNav+MiniPlaybar |
| `layout/navbar/index.tsx` | (BottomNavigationBar in app_router.dart) | 📱 Mobile adaptation | Top navbar → Bottom navigation |
| `layout/side/index.tsx` | (BottomNavigationBar replaces sidebar) | 📱 Mobile adaptation | Sidebar → Bottom tabs |
| `layout/side/logo/index.tsx` | - | 📱 Mobile adaptation | Logo in sidebar not needed |
| `layout/side/default-menu/index.tsx` | `core/router/app_router.dart` | 📱 Mobile adaptation | Sidebar menus → Bottom tabs + Profile menu |
| `common/constants/menus.tsx` | (Route entries in app_router.dart) | ✅ Full | All menu items accessible via routes |
| `routes.tsx` | `core/router/routes.dart` | ✅ | |
| `app.tsx` | `main.dart` | ✅ | |
| `index.tsx` | `main.dart` | ✅ | |
| - | `core/router/auth_guard.dart` | 🆕 Flutter-only | |

**Menu Function Coverage** (from `menus.tsx`):
- 热歌精选 (/) → Flutter: Home tab ✅
- 音乐大咖 (/artist-rank) → Flutter: AppRoutes.artistRank ✅
- 推荐音乐 (/music-recommend) → Flutter: AppRoutes.musicRecommend ✅
- 我的关注 (/follow) → Flutter: AppRoutes.followList ✅
- 稀后再看 (/later) → Flutter: AppRoutes.later ✅
- 历史记录 (/history) → Flutter: History tab ✅
- 下载记录 (/download-list) → 🖥️ Desktop-only

---

## Boundary Inconsistencies

### 1. Architecture Pattern Mismatch

**Issue:** Electron uses flat service files (one file per API), Flutter consolidates into DataSource classes.

**Impact:** When updating from Electron, need to locate the correct method in the DataSource class rather than a separate file.

**Example:**
- Electron: `fav-folder-add.ts`, `fav-folder-edit.ts`, `fav-folder-del.ts` (3 files)
- Flutter: All in `favorites_remote_datasource.dart` as methods

### 2. State Management Migration

**Issue:** Electron uses Zustand stores, Flutter uses Riverpod StateNotifier.

**Impact:** State structure is similar but migration requires understanding both patterns.

**Example:**
- Electron: `usePlayList` (Zustand store with persist middleware)
- Flutter: `PlaylistNotifier` (StateNotifier) + `PlaylistState` (Freezed class)

### 3. Navigation Structure

**Issue:** Desktop uses sidebar + navbar, Mobile uses bottom navigation.

**Impact:** Layout components don't map directly.

**Electron Layout:**
```
+---------------------------+
| Navbar (search, user)     |
+-------+-------------------+
| Side  |    Content        |
| bar   |    Area           |
|       +-------------------+
|       |    Playbar        |
+-------+-------------------+
```

**Flutter Layout:**
```
+---------------------------+
|    Content Area           |
|                           |
+---------------------------+
|    Mini Playbar           |
+---------------------------+
| Bottom Navigation Bar     |
+---------------------------+
```

### 4. Geetest Verification

**Issue:** Flutter's WebView-based Geetest only works on mobile platforms.

**Impact:** Windows/Linux Flutter builds cannot use Geetest verification.

**Electron:** Uses script injection in renderer process
**Flutter:** Uses WebView (Android/iOS only)

### 5. Download Functionality

**Issue:** Download feature is entirely desktop-specific (requires FFmpeg, file system access).

**Impact:** Flutter mobile version has no download capability.

### 6. One-to-Many File Splits

Several Electron files map to multiple Flutter files due to different patterns:

| Electron | Flutter Files | Reason |
|----------|---------------|--------|
| `utils/time.ts` | `datetime_extensions.dart` + `duration_extensions.dart` | Extension pattern by type |
| `utils/url.ts` | `url_utils.dart` + `string_extensions.dart` | Mixed responsibilities |
| `response-interceptors.ts` | `response_interceptor.dart` + `logging_interceptor.dart` | Separation of concerns |

**Note:** `utils/number.ts` now maps 1:1 to `number_utils.dart` (duplicate `format_utils.dart` was deleted).

---

## Missing Features

### High Priority (Core Functionality)

1. **Download Feature** - No audio/video download capability (Desktop-only, requires FFmpeg)
2. **Gaia VGate Verification** - Missing risk control verification (WebView-based on mobile)

### Medium Priority (Enhanced Features)

1. **Audio Song Info** - `audio-song-info.ts` not implemented
2. **Audio Rank** - `audio-rank.ts` not implemented

### Low Priority (Desktop-Specific)

1. **Shortcut Keys** - Desktop keyboard shortcuts
2. **Mini Player Window** - Separate window mode
3. **Font Selection** - Custom font support
4. **Window Close Options** - Minimize to tray
5. **Auto Start** - System startup option
6. **FFmpeg Integration** - Video/audio processing

### Not Needed (Evaluated and Determined Unnecessary)

| Feature | Reason |
|---------|--------|
| `space-navnum.ts` | Nav badge counts not used in mobile music player UI |
| `space-masterpiece.ts` | B站特有功能, 网易云/QQ音乐都没有代表作功能 |
| `space-top-arc.ts` | B站特有功能, 置顶视频不适用于音乐播放器 |
| `space-seasons-series-list.ts` | B站特有功能, 视频合集不适用于音乐播放器 |
| `web-dynamic.ts` | Source code filters to video dynamics only, overlaps with video posts |
| `web-dynamic-feed-thumb.ts` | Depends on dynamic feature |
| `video-series.tsx` | B站特有功能 |
| `dynamic-list/` | Overlaps with video posts |
| `components/dynamic-feed/` | Overlaps with video posts |
| `web-interface-view-detail.ts` | Tags/Comments/Related are for video detail page, not needed for music player |
| `web-interface-archive-desc.ts` | Description already in view API response |
| `web-interface-ranking.ts` | Video ranking, not music ranking. Music uses music-hot-rank |

### Already Implemented (Removed from Missing)

- ~~Music Rank Screen~~ → Home screen displays hot songs
- ~~Music Recommend Feature~~ → `/music-recommend` route with infinite scroll
- ~~Country List API~~ → Dynamic country list in SMS login
- ~~Video Detail API~~ → Not needed for music player
- ~~Video Page List UI~~ → `_VideoPageListSheet` in full_player_screen.dart
- ~~Volume Slider~~ → `_buildVolumeControl` with popup vertical slider
- ~~Quick Favorite~~ → `_showFavoriteSheet` in full_player_screen.dart AppBar
- ~~User Favorites Tab~~ → `user_favorites_tab.dart` with space-setting API


---

## Version Information

- **Document Updated:** 2025-12-24
- **Source Project:** biu (Electron + React + TypeScript)
- **Target Project:** biu_flutter (Flutter + Dart)
- **Analysis Method:** Automated subagent file-by-file comparison with source code reading
