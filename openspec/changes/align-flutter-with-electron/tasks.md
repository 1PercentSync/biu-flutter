# Implementation Tasks - Flutter Alignment

## Agent Instructions

This task list is designed for autonomous agent implementation. After completing each task:
1. Ensure code compiles: `flutter analyze`
2. Run tests if applicable: `flutter test`
3. Commit changes: `git commit -m "type(scope): description"`
4. Push to remote: `git push`

**Priority Legend:**
- [P0] Critical - Must fix before release
- [P1] Important - Core feature parity
- [P2] Enhancement - Nice to have

---

## Phase A: Critical Fixes [P0]

### A.1 Search Module Alignment

#### A.1.1 "Music Only" Filter [P0]
- [x] A.1.1.1 Add `musicOnly` state to search provider
  - Default: `true` (match source behavior)
  - Location: `lib/features/search/presentation/providers/`
  - Reference: `biu/src/pages/search/index.tsx:15` (`musicOnly` state)

- [x] A.1.1.2 Update search API call to include `tids` parameter
  - When musicOnly=true, pass `tids: 3` (music category)
  - Location: `lib/features/search/data/datasources/search_remote_datasource.dart`
  - Reference: `biu/src/pages/search/index.tsx:50-55`

- [x] A.1.1.3 Add "Music Only" toggle switch to search UI
  - Position: Below search bar or in filter area
  - Location: `lib/features/search/presentation/screens/search_screen.dart`
  - Reference: `biu/src/pages/search/index.tsx:102-107` (Switch component)

#### A.1.2 Search History [P0]
- [x] A.1.2.1 Create SearchHistoryItem model
  ```dart
  class SearchHistoryItem {
    final String value;
    final int timestamp;
  }
  ```
  - Location: `lib/features/search/domain/entities/search_history_item.dart`
  - Reference: `biu/src/store/search-history.ts:5-8`

- [x] A.1.2.2 Create SearchHistoryNotifier with persistence
  - Methods: `add(value)`, `delete(item)`, `clear()`
  - Persistence key: `search-history`
  - Max items: 20 (prevent unlimited growth)
  - Location: `lib/features/search/presentation/providers/search_history_notifier.dart`
  - Reference: `biu/src/store/search-history.ts`

- [x] A.1.2.3 Add search history UI to search screen
  - Display on focus when query is empty
  - Chip/tag style with delete button
  - "Clear All" button
  - Tap to search
  - Location: `lib/features/search/presentation/widgets/search_history_widget.dart`
  - Reference: `biu/src/layout/navbar/search/index.tsx:60-100`

#### A.1.3 Search Pagination [P1]
- [x] A.1.3.1 Add pagination state to search provider
  - Fields: `currentPage`, `totalPages`, `hasMore`
  - Location: `lib/features/search/presentation/providers/`
  - Reference: `biu/src/pages/search/index.tsx`

- [x] A.1.3.2 Implement load more functionality
  - Trigger: Scroll to bottom or "Load More" button
  - Location: `lib/features/search/presentation/screens/search_screen.dart`
  - Reference: `biu/src/pages/search/video-list.tsx`

- [x] A.1.3.3 Add pagination UI component
  - Option A: Infinite scroll with loading indicator
  - Option B: Page number buttons (like source)
  - Reference: Source uses HeroUI Pagination component

#### A.1.4 User Search Tab [P1]
- [x] A.1.4.1 Create user search result model
  - Fields: mid, uname, usign, upic, fans, videos, level
  - Location: `lib/features/search/data/models/search_user_result.dart`
  - Reference: `biu/src/pages/search/search-type.tsx`

- [x] A.1.4.2 Implement user search API call
  - Already defined but unused: `searchUser()` in datasource
  - Location: `lib/features/search/data/datasources/search_remote_datasource.dart`

- [x] A.1.4.3 Add TabBar for Video/User search
  - Location: `lib/features/search/presentation/screens/search_screen.dart`
  - Reference: `biu/src/pages/search/search-type.tsx`

- [x] A.1.4.4 Create UserSearchResultCard widget
  - Display: Avatar, name, signature, fans count
  - Location: `lib/features/search/presentation/widgets/user_search_card.dart`
  - Reference: `biu/src/pages/search/user-list.tsx`

---

### A.2 Player Module Alignment

#### A.2.1 URL Validity Checking [P0]
- [x] A.2.1.1 Create `isUrlValid()` utility function
  ```dart
  bool isUrlValid(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    final deadline = uri?.queryParameters['deadline'];
    if (deadline == null) return true;
    final deadlineTime = int.tryParse(deadline) ?? 0;
    return DateTime.now().millisecondsSinceEpoch / 1000 < deadlineTime;
  }
  ```
  - Location: `lib/core/utils/url_utils.dart`
  - Reference: `biu/src/common/utils/audio.ts:123-126`

- [x] A.2.1.2 Integrate URL check in `_ensureAudioUrlValid()`
  - Check validity BEFORE attempting playback
  - If invalid, fetch fresh URL immediately
  - Location: `lib/features/player/presentation/providers/playlist_notifier.dart:577`
  - Reference: `biu/src/store/play-list.ts:247-260`

#### A.2.2 Audio Quality Selection [P0]
- [x] A.2.2.1 Create UserAudioQuality enum
  ```dart
  enum UserAudioQuality {
    auto('auto', 'Auto'),
    high('high', 'High (192K)'),
    medium('medium', 'Medium (132K)'),
    low('low', 'Low (64K)'),
    lossless('lossless', 'Lossless');
  }
  ```
  - Location: `lib/core/constants/audio.dart`
  - Reference: `biu/shared/types/app-setting.d.ts:1`
  - Note: Used existing `AudioQualitySetting` enum from `lib/features/settings/domain/entities/app_settings.dart`

- [x] A.2.2.2 Add quality selection to settings
  - Use current AudioQualitySetting or merge
  - Location: `lib/features/settings/domain/entities/app_settings.dart`
  - Reference: `biu/shared/settings/app-settings.ts`
  - Note: Already implemented

- [x] A.2.2.3 Implement `selectAudioByQuality()` function
  ```dart
  DashAudio? selectAudioByQuality(List<DashAudio> audioList, UserAudioQuality quality) {
    final sorted = sortAudioByQuality(audioList);
    switch (quality) {
      case UserAudioQuality.high: return sorted.first;
      case UserAudioQuality.medium: return sorted[sorted.length ~/ 2];
      case UserAudioQuality.low: return sorted.last;
      default: return sorted.first;
    }
  }
  ```
  - Location: `lib/features/video/data/models/play_url.dart`
  - Reference: `biu/src/common/utils/audio.ts:26-43`

- [x] A.2.2.4 Apply quality preference in audio URL fetch
  - Read from settings provider
  - Pass to URL selection logic
  - Location: `lib/features/player/services/audio_service_init.dart`
  - Reference: `biu/src/common/utils/audio.ts:45-100`

#### A.2.3 Multi-Part Video addToNext Fix [P1]
- [x] A.2.3.1 Update `addToNext()` logic for MV type
  - For MV: Insert after last page of current video
  - For Audio: Insert after current item
  - Location: `lib/features/player/presentation/providers/playlist_notifier.dart:294`
  - Reference: `biu/src/store/play-list.ts:729-745`

#### A.2.4 Playback Rate UI [P1]
- [x] A.2.4.1 Add rate selector to full player screen
  - Options: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x
  - Location: `lib/shared/widgets/playbar/full_player_screen.dart`
  - Reference: `biu/src/layout/playbar/right/rate.tsx`
  - Note: Already implemented as `_RateDialog` with matching rate options

- [x] A.2.4.2 Create rate picker bottom sheet widget
  - Location: `lib/shared/widgets/playbar/rate_picker_sheet.dart`
  - Reference: `biu/src/layout/playbar/right/rate.tsx`
  - Note: Implemented as dialog instead of bottom sheet (better for mobile UX)

---

### A.3 Authentication Alignment

#### A.3.1 Geetest SDK Integration [P0]
- [x] A.3.1.1 Research Flutter Geetest SDK options
  - Decision: WebView-based approach using flutter_inappwebview
  - Documented in design.md (D1 decision)

- [x] A.3.1.2 Implement Geetest captcha trigger
  - Created `GeetestNotifier` to trigger captcha verification
  - Location: `lib/features/auth/presentation/providers/geetest_notifier.dart`
  - Reference: `biu/src/common/hooks/use-geetest.ts`

- [x] A.3.1.3 Create GeetestDialog widget
  - WebView-based captcha dialog
  - Returns validation result via JavaScript bridge
  - Location: `lib/features/auth/presentation/widgets/geetest_dialog.dart`
  - Reference: `biu/src/common/utils/geetest.ts`

- [x] A.3.1.4 Integrate Geetest with password login
  - Captcha triggers before password login
  - Location: `lib/features/auth/presentation/widgets/password_login_widget.dart`
  - Reference: `biu/src/layout/navbar/login/password-login.tsx`

- [x] A.3.1.5 Integrate Geetest with SMS login
  - Captcha required before sending SMS code
  - Location: `lib/features/auth/presentation/widgets/sms_login_widget.dart`
  - Reference: `biu/src/layout/navbar/login/code-login.tsx`

#### A.3.2 Cookie Refresh Mechanism [P1]
- [x] A.3.2.1 Implement CorrespondPath fetch for refresh_csrf
  - RSA-OAEP encryption for correspondPath
  - HTML parsing for refresh_csrf
  - Location: `lib/features/auth/data/services/cookie_refresh_service.dart`
  - Reference: `biu/src/common/utils/cookie.ts`

- [x] A.3.2.2 Complete `refreshCookie()` flow
  - Full flow: getCookieInfo -> getCorrespondPath -> refreshCookie -> confirmRefresh
  - Location: `lib/features/auth/presentation/providers/auth_notifier.dart`
  - Reference: `biu/src/store/token.ts`

#### A.3.3 Bili Ticket Injection [P1]
- [x] A.3.3.1 Implement bili_ticket service
  - Fetch and cache bili_ticket with HMAC-SHA256 signature
  - Auto-refresh before expiry (3 days)
  - Location: `lib/core/network/ticket/bili_ticket_service.dart`
  - Reference: `biu/electron/network/web-bili-ticket.ts`

- [x] A.3.3.2 Inject bili_ticket in auth interceptor
  - Adds bili_ticket to cookies for all requests
  - Location: `lib/core/network/interceptors/auth_interceptor.dart`
  - Reference: `biu/electron/network/cookie.ts`

---

## Phase B: Content Pages [P1]

### B.1 Music Rank (Homepage) [P0]

#### B.1.1 Music Rank API
- [x] B.1.1.1 Create music rank data models
  - HotSong model with fields: id, musicId, musicTitle, author, bvid, aid, cid, cover, album, totalVv, wishCount
  - Location: `lib/features/music_rank/data/models/hot_song.dart`
  - Reference: `biu/src/service/music-hot-rank.ts`

- [x] B.1.1.2 Implement music rank API datasource
  - GET `/x/centralization/interface/music/hot/rank`
  - Location: `lib/features/music_rank/data/datasources/music_rank_remote_datasource.dart`
  - Reference: `biu/src/service/music-hot-rank.ts`

#### B.1.2 Music Rank UI
- [x] B.1.2.1 Create MusicRankScreen
  - Integrated into HomeScreen with grid display
  - Tap to play functionality via PlaylistNotifier
  - Location: `lib/features/home/presentation/screens/home_screen.dart`
  - Reference: `biu/src/pages/music-rank/index.tsx`

- [x] B.1.2.2 Replace home screen with music rank
  - HomeScreen now displays MusicRank content
  - Location: `lib/features/home/presentation/screens/home_screen.dart`

- [x] B.1.2.3 Create HotSongCard widget
  - Rank number badge (with color for top 3), cover, title, artist, play count
  - Also includes HotSongListTile for list view mode
  - Location: `lib/features/music_rank/presentation/widgets/hot_song_card.dart`
  - Reference: `biu/src/pages/music-rank/index.tsx`

### B.2 Artist Rank [P1]

- [ ] B.2.1 Implement artist/musician list API
  - Location: `lib/features/artist_rank/data/datasources/`
  - Reference: `biu/src/service/musician-list.ts`

- [ ] B.2.2 Create ArtistRankScreen
  - Location: `lib/features/artist_rank/presentation/screens/`
  - Reference: `biu/src/pages/artist-rank/index.tsx`

### B.3 Watch History [P0]

#### B.3.1 History API
- [x] B.3.1.1 Create history data models
  - HistoryItem, CursorInfo, HistoryDetail, HistoryBusinessType, HistoryFilterType
  - Location: `lib/features/history/data/models/history_item.dart`
  - Reference: `biu/src/service/web-interface-history-cursor.ts`

- [x] B.3.1.2 Implement cursor-based history API
  - GET `/x/web-interface/history/cursor`
  - Support cursor pagination with HistoryCursorResponse
  - Location: `lib/features/history/data/datasources/history_remote_datasource.dart`
  - Reference: `biu/src/service/web-interface-history-cursor.ts`

#### B.3.2 History UI
- [x] B.3.2.1 Create HistoryScreen
  - Infinite scroll with cursor pagination
  - HistoryItemCard with progress bar, duration badge, view time
  - Location: `lib/features/history/presentation/screens/history_screen.dart`
  - Reference: `biu/src/pages/history/index.tsx`

- [x] B.3.2.2 Add History to navigation
  - Added route in routes.dart and app_router.dart
  - Added History tab in bottom navigation (5 tabs total)
  - Location: `lib/core/router/`

### B.4 Watch Later [P0]

#### B.4.1 Watch Later API
- [ ] B.4.1.1 Implement toview list API
  - GET `/x/v2/history/toview`
  - Location: `lib/features/later/data/datasources/later_remote_datasource.dart`
  - Reference: `biu/src/service/history-toview-list.ts`

- [ ] B.4.1.2 Implement add to later API
  - POST `/x/v2/history/toview/add`
  - Reference: `biu/src/service/history-toview-add.ts`

- [ ] B.4.1.3 Implement remove from later API
  - POST `/x/v2/history/toview/del`
  - Reference: `biu/src/service/history-toview-del.ts`

#### B.4.2 Watch Later UI
- [ ] B.4.2.1 Create LaterScreen
  - Location: `lib/features/later/presentation/screens/later_screen.dart`
  - Reference: `biu/src/pages/later/index.tsx`

- [ ] B.4.2.2 Add "Watch Later" button to video items
  - In search results, favorites, etc.
  - Reference: Source has toview actions in menus

### B.5 Following List [P1]

#### B.5.1 Relation API
- [ ] B.5.1.1 Implement followings API
  - GET `/x/relation/followings`
  - Location: `lib/features/follow/data/datasources/relation_remote_datasource.dart`
  - Reference: `biu/src/service/relation-followings.ts`

- [ ] B.5.1.2 Implement follow/unfollow API
  - POST `/x/relation/modify`
  - Reference: `biu/src/service/relation-modify.ts`

#### B.5.2 Following UI
- [ ] B.5.2.1 Create FollowListScreen
  - Grid of followed users
  - Tap to view user's content
  - Location: `lib/features/follow/presentation/screens/follow_list_screen.dart`
  - Reference: `biu/src/pages/follow-list/index.tsx`

### B.6 User Profile Enhancement [P1]

- [ ] B.6.1 Implement user space APIs
  - Space info: `/x/space/wbi/acc/info`
  - Space videos: `/x/space/wbi/arc/search`
  - Reference: `biu/src/service/space-wbi-*.ts`

- [ ] B.6.2 Create enhanced UserProfileScreen
  - User info header
  - Videos tab
  - Reference: `biu/src/pages/user-profile/index.tsx`

---

## Phase C: Feature Completion [P2]

### C.1 Favorites Enhancement

#### C.1.1 Folder Search/Filter [P1]
- [ ] C.1.1.1 Add search input to folder detail screen
  - Filter by keyword parameter
  - Location: `lib/features/favorites/presentation/screens/folder_detail_screen.dart`
  - Reference: `biu/src/pages/video-collection/favorites.tsx:25-35`

- [ ] C.1.1.2 Add sort options dropdown
  - Options: mtime (default), view, pubtime
  - Reference: `biu/src/pages/video-collection/favorites.tsx:70-80`

#### C.1.2 Batch Operations [P1]
- [ ] C.1.2.1 Implement batch delete API
  - POST `/x/v3/fav/resource/batch-del`
  - Location: `lib/features/favorites/data/datasources/favorites_remote_datasource.dart`
  - Reference: `biu/src/service/fav-resource-batch-del.ts`

- [ ] C.1.2.2 Implement batch move API
  - POST `/x/v3/fav/resource/move`
  - Reference: `biu/src/service/fav-resource-move.ts`

- [ ] C.1.2.3 Implement batch copy API
  - POST `/x/v3/fav/resource/copy`
  - Reference: `biu/src/service/fav-resource-copy.ts`

- [ ] C.1.2.4 Add multi-select mode to folder detail
  - Long press to enter selection mode
  - Bottom action bar with batch actions
  - Reference: Source has checkbox selection

#### C.1.3 Play All [P1]
- [ ] C.1.3.1 Add "Play All" button to folder detail header
  - Replaces current playlist with folder contents
  - Location: `lib/features/favorites/presentation/screens/folder_detail_screen.dart`
  - Reference: `biu/src/pages/video-collection/info/index.tsx`

- [ ] C.1.3.2 Add "Add All to Queue" option
  - Appends to current playlist
  - Reference: Same as above

#### C.1.4 Clean Invalid Items [P2]
- [ ] C.1.4.1 Implement clean invalid API
  - POST `/x/v3/fav/resource/clean`
  - Reference: `biu/src/service/fav-resource-clean.ts`

- [ ] C.1.4.2 Add "Clean Invalid" menu option
  - In folder detail more menu
  - Reference: Source has this in folder menu

### C.2 Settings Enhancement

#### C.2.1 Display Mode [P2]
- [ ] C.2.1.1 Add displayMode to AppSettings
  - Values: 'card' | 'list'
  - Location: `lib/features/settings/domain/entities/app_settings.dart`
  - Reference: `biu/shared/types/app-setting.d.ts:14`

- [ ] C.2.1.2 Add display mode toggle to settings
  - Location: `lib/features/settings/presentation/screens/settings_screen.dart`
  - Reference: `biu/src/pages/settings/index.tsx`

- [ ] C.2.1.3 Apply display mode to list screens
  - Favorites, search results, etc.
  - Reference: Source applies `displayMode` to GridList

#### C.2.2 Menu Customization [P2]
- [ ] C.2.2.1 Add hiddenMenuKeys to AppSettings
  - Store IDs of hidden favorites folders
  - Reference: `biu/shared/types/app-setting.d.ts:13`

- [ ] C.2.2.2 Add menu settings section
  - Toggle visibility of individual folders
  - Reference: `biu/src/pages/settings/index.tsx` (menu tab)

---

## Verification Tasks

### V.1 Integration Tests
- [ ] V.1.1 Test search with music filter
- [ ] V.1.2 Test search history persistence
- [ ] V.1.3 Test URL validity checking
- [ ] V.1.4 Test audio quality selection
- [ ] V.1.5 Test batch favorites operations

### V.2 UI/UX Verification
- [ ] V.2.1 Compare search UI with source
- [ ] V.2.2 Compare player UI with source
- [ ] V.2.3 Compare favorites UI with source
- [ ] V.2.4 Verify music rank displays correctly

### V.3 Source Parity Check
- [ ] V.3.1 Run through all user flows
- [ ] V.3.2 Document any remaining differences
- [ ] V.3.3 Create issues for post-release improvements

---

## Already Implemented (Reference Only)

The following tasks from the original migration are complete and need no changes:

### Core Infrastructure ✅
- Project setup, dependencies
- Directory structure
- Navigation (go_router)
- Local storage

### Bilibili API Client ✅
- Dio configuration
- WBI signature
- BUVID generation
- Basic API services

### Authentication ✅ (Partial - see A.3 for gaps)
- QR login flow
- Password login (without Geetest)
- SMS login (without Geetest)
- Session management (partial refresh)

### Audio Player ✅ (Partial - see A.2 for gaps)
- Playback engine
- Playlist management
- Play modes
- Media session

### UI ✅
- Theme configuration
- Main layout
- Playbar (mini and full)
- Common widgets

### Favorites ✅ (Partial - see C.1 for gaps)
- Basic CRUD
- Folder listing
- Resource listing

### Settings ✅ (Partial - see C.2 for gaps)
- Audio quality
- Theme color
- About screen
