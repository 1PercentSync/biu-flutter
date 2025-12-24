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

| Category | Total Source Files | Fully Mapped | Partially Mapped | Not Mapped |
|----------|-------------------|--------------|------------------|------------|
| Constants | 7 | 2 | 0 | 5 |
| Utils/Hooks | 13 | 2 | 4 | 7 |
| Network/Service | 6 | 6 | 0 | 0 |
| Auth | 17 | 14 | 0 | 3 |
| Favorites | 18 | 14 | 0 | 4 |
| Player | 20 | 17 | 1 | 2 |
| Search/History/Later | 12 | 12 | 0 | 0 |
| User Profile/Follow | 15 | 10 | 0 | 5 |
| Music/Artist Rank | 6 | 4 | 0 | 2 |
| Settings | 7 | 6 | 1 | 0 |
| Shared Components | 30 | 6 | 2 | 22 |
| Layout | 15 | 5 | 3 | 7 |
| Video/Download | 10 | 3 | 0 | 7 |
| **Total** | **176** | **99** | **12** | **65** |

**Overall Migration Rate: ~56% fully mapped, 7% partially mapped, 37% not mapped**

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

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `store/play-list.ts` | `features/player/presentation/providers/playlist_notifier.dart` + `playlist_state.dart` | ✅ |
| `store/play-progress.ts` | (integrated into playlist_notifier.dart) | ✅ |
| `service/player-playurl.ts` | `features/video/data/datasources/video_remote_datasource.dart` | ✅ |
| `service/player-pagelist.ts` | (integrated into video_remote_datasource.dart) | ✅ |
| `service/audio-web-url.ts` | `features/audio/data/datasources/audio_remote_datasource.dart` | ✅ |
| `service/audio-song-info.ts` | - | ❌ Missing |
| `service/audio-rank.ts` | - | ❌ Missing |
| `layout/playbar/index.tsx` | `shared/widgets/playbar/playbar.dart` (barrel) | ✅ |
| `layout/playbar/left/index.tsx` | `shared/widgets/playbar/mini_playbar.dart` | ✅ |
| `layout/playbar/center/index.tsx` | ↳ + `full_player_screen.dart` | ✅ |
| `layout/playbar/center/progress.tsx` | ↳ (integrated) | ✅ |
| `layout/playbar/right/index.tsx` | `shared/widgets/playbar/full_player_screen.dart` | ✅ |
| `layout/playbar/right/play-mode.tsx` | ↳ (integrated) | ✅ |
| `layout/playbar/right/rate.tsx` | ↳ (_RateDialog) | ✅ |
| `layout/playbar/right/volume.tsx` | ↳ (mute only, no slider) | ⚠️ Partial |
| `layout/playbar/right/play-list-drawer/` | ↳ (_PlaylistSheet) | ✅ |
| `layout/playbar/right/download.tsx` | - | ❌ Missing |
| `layout/playbar/right/mv-fav-folder-select.tsx` | - | ❌ Missing |
| `layout/playbar/left/video-page-list/` | - | ❌ Missing |
| `pages/mini-player/*` | - | ❌ Desktop-only |
| - | `shared/widgets/playbar/full_player_screen.dart` | 🆕 Flutter-only |

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

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/space-wbi-acc-info.ts` | `features/user_profile/data/datasources/user_profile_remote_datasource.dart` | ✅ |
| `service/space-wbi-acc-relation.ts` | ↳ (getSpaceRelation) | ✅ |
| `service/space-wbi-arc-search.ts` | ↳ (getSpaceVideos) | ✅ |
| `service/relation-stat.ts` | ↳ (getRelationStat) | ✅ |
| `service/space-navnum.ts` | - | ❌ Missing |
| `service/space-masterpiece.ts` | - | ❌ Missing |
| `service/space-top-arc.ts` | - | ❌ Missing |
| `service/space-setting.ts` | - | ❌ Missing |
| `service/space-seasons-series-list.ts` | - | ❌ Missing |
| `service/relation-followings.ts` | `features/follow/data/datasources/follow_remote_datasource.dart` | ✅ |
| `service/relation-modify.ts` | ↳ (modifyRelation, followUser, unfollowUser) | ✅ |
| `service/web-dynamic.ts` | - | ❌ Missing |
| `service/web-dynamic-feed-thumb.ts` | - | ❌ Missing |
| `pages/user-profile/index.tsx` | `features/user_profile/presentation/screens/user_profile_screen.dart` | ✅ |
| `pages/user-profile/space-info.tsx` | `features/user_profile/presentation/widgets/space_info_header.dart` | ✅ |
| `pages/user-profile/video-post.tsx` | `features/user_profile/presentation/widgets/video_post_card.dart` | ✅ |
| `pages/user-profile/favorites.tsx` | - | ❌ Missing |
| `pages/user-profile/video-series.tsx` | - | ❌ Missing |
| `pages/user-profile/dynamic-list/` | - | ❌ Missing |
| `pages/follow-list/index.tsx` | `features/follow/presentation/screens/follow_list_screen.dart` | ✅ |
| `pages/follow-list/user-card.tsx` | `features/follow/presentation/widgets/following_card.dart` | ✅ |
| `components/dynamic-feed/` | - | ❌ Missing |

---

### 8. Music/Artist Rank Modules

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/music-hot-rank.ts` | `features/music_rank/data/datasources/music_rank_remote_datasource.dart` | ✅ |
| `pages/music-rank/index.tsx` | - | ❌ Missing Screen |
| `service/music-comprehensive-web-rank.ts` | - | ❌ Missing |
| `pages/music-recommend/index.tsx` | - | ❌ Missing |
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

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `components/empty/index.tsx` | `shared/widgets/empty_state.dart` | ✅ |
| `components/error-fallback/index.tsx` | `shared/widgets/error_state.dart` | ✅ |
| `components/image/index.tsx` | `shared/widgets/cached_image.dart` | ✅ |
| `components/music-list-item/index.tsx` | `shared/widgets/track_list_item.dart` | ✅ (highlightTitle + onArtistTap) |
| `components/mv-card/index.tsx` | `shared/widgets/video_card.dart` | ✅ (highlightTitle + onOwnerTap) |
| `components/image-card/index.tsx` | `shared/widgets/video_card.dart` | ✅ |
| `components/music-list-item/index.tsx#isTitleIncludeHtmlTag` | `shared/widgets/highlighted_text.dart` | 🆕 New |
| `components/image-card/skeleton.tsx` | - | ❌ Missing |
| `components/confirm-modal/index.tsx` | - | ❌ Missing |
| `components/mv-action/index.tsx` | - | ❌ Missing |
| `components/async-button/index.tsx` | - | ❌ Missing |
| `components/audio-waveform/index.tsx` | - | ❌ Missing |
| `components/ellipsis/index.tsx` | - | ❌ Missing |
| `components/grid-list/index.tsx` | - | ❌ Missing |
| `components/if/index.tsx` | - | ❌ Flutter native syntax |
| `components/menu/` | - | ❌ Missing |
| `components/scroll-container/index.tsx` | - | ❌ Missing |
| `components/search-filter/index.tsx` | - | ❌ Missing |
| `components/select-all-checkbox-group/index.tsx` | - | ❌ Missing |
| `components/shortcut-key-input/index.tsx` | - | ❌ Desktop-only |
| `components/typography/index.tsx` | - | ❌ Missing |
| `components/update-check-button/index.tsx` | - | ❌ Desktop-only |
| `components/video-pages-download-select-modal/index.tsx` | - | ❌ Missing |
| `components/virtual-list/index.tsx` | - | ❌ Missing |
| `components/release-note-modal/index.tsx` | - | ❌ Missing |
| `components/font-select/index.tsx` | - | ❌ Desktop-only |
| `components/theme/index.tsx` | `shared/theme/app_theme.dart` | ✅ |
| - | `shared/widgets/async_value_widget.dart` | 🆕 Flutter-only |
| - | `shared/widgets/loading_state.dart` | 🆕 Flutter-only |

---

### 11. Video / Download

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `service/web-interface-view.ts` | `features/video/data/datasources/video_remote_datasource.dart` | ✅ |
| `service/web-interface-view-detail.ts` | - | ❌ Missing |
| `service/web-interface-archive-desc.ts` | - | ❌ Missing |
| `service/web-interface-ranking.ts` | - | ❌ Missing |
| `pages/download-list/` | - | ❌ Desktop-only |
| `components/video-pages-download-select-modal/` | - | ❌ Missing |
| `store/modal/video-page-download-modal.ts` | - | ❌ Missing |
| `shared/types/download.d.ts` | - | ❌ Desktop-only |
| `electron/ipc/download/` | - | ❌ Desktop-only |

---

### 12. Layout / Routing

| Electron Source | Flutter Target | Status |
|-----------------|----------------|--------|
| `layout/index.tsx` | `core/router/app_router.dart` (MainShell) | ⚠️ Different structure |
| `layout/navbar/index.tsx` | (BottomNavigationBar in app_router.dart) | ⚠️ Different structure |
| `layout/side/index.tsx` | (BottomNavigationBar replaces sidebar) | ⚠️ Different structure |
| `layout/side/logo/index.tsx` | - | ❌ Mobile nav different |
| `layout/side/default-menu/index.tsx` | - | ❌ Mobile nav different |
| `routes.tsx` | `core/router/routes.dart` | ✅ |
| `app.tsx` | `main.dart` | ✅ |
| `index.tsx` | `main.dart` | ✅ |
| - | `core/router/auth_guard.dart` | 🆕 Flutter-only |

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

1. **Video Page List UI** - Cannot browse/switch video parts during playback
2. **Download Feature** - No audio/video download capability
3. **Gaia VGate Verification** - Missing risk control verification
4. **Video Series Support** - No season/series collection support
5. **Music Rank Screen** - Data layer exists but no screen component
6. **Music Recommend Feature** - Completely missing

### Medium Priority (Enhanced Features)

1. **Dynamic Feed** - User dynamics not implemented
2. **Volume Slider** - Only mute toggle, no precise control
3. **Quick Favorite** - No quick add-to-favorites from playbar
4. **Video Detail API** - Missing tags, hot comments, related videos
5. **Country List API** - Hardcoded instead of API
6. **User Masterpiece/Top Videos** - User profile incomplete

### Low Priority (Desktop-Specific)

1. **Shortcut Keys** - Desktop keyboard shortcuts
2. **Mini Player Window** - Separate window mode
3. **Font Selection** - Custom font support
4. **Window Close Options** - Minimize to tray
5. **Auto Start** - System startup option
6. **FFmpeg Integration** - Video/audio processing

---

## Version Information

- **Document Generated:** 2024-12-24
- **Source Project:** biu (Electron + React + TypeScript)
- **Target Project:** biu_flutter (Flutter + Dart)
- **Analysis Method:** Automated subagent file-by-file comparison with source code reading
