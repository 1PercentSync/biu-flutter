# Change: Align Flutter Implementation with Electron Source Project

## Why

The Flutter migration (Phase 1-8) established core functionality, but detailed comparison reveals significant gaps between the Flutter implementation and the original Electron project. These gaps affect:

1. **Core User Experience** - Missing "music only" search filter (original default), no search history
2. **Feature Completeness** - Missing content pages (music rank, history, later, follow)
3. **Functional Parity** - Incomplete URL validity checking, audio quality selection, batch operations
4. **Authentication Robustness** - Missing Geetest SDK, incomplete cookie refresh mechanism

This alignment change ensures the Flutter app provides equivalent functionality to the source Electron app before iOS release.

## What Changes

### Phase A: Critical Fixes (P0)

1. **Search Module Alignment**
   - Add "music only" toggle (tids: 3 filter) - **CRITICAL for music app**
   - Implement search history with persistence
   - Add search results pagination
   - Add user search tab

2. **Player Module Alignment**
   - Implement URL deadline-based validity checking
   - Add user-selectable audio quality (auto/high/medium/low/lossless)
   - Fix addToNext for multi-part videos
   - Add playback rate adjustment UI

3. **Authentication Alignment**
   - Implement Geetest SDK integration for captcha verification
   - Complete cookie refresh mechanism (CorrespondPath + refresh_csrf)
   - Add bili_ticket auto-injection

### Phase B: Content Pages (P1)

4. **Missing Pages Implementation**
   - Music Rank (Hot Songs) - **Homepage content**
   - Artist Rank
   - Watch History
   - Watch Later
   - Following List
   - User Profile (complete)

5. **Related APIs**
   - Music rank APIs
   - History APIs (cursor-based pagination)
   - Watch later APIs (CRUD)
   - Relation APIs (followings)
   - Space APIs (user profile details)

### Phase C: Feature Completion (P2)

6. **Favorites Enhancement**
   - Search/filter within folder
   - Sort options (mtime/view/pubtime)
   - Batch operations (delete/move/copy)
   - "Play All" functionality
   - Clean invalid items

7. **Settings Enhancement**
   - Display mode toggle (card/list)
   - Menu customization (hide folders)
   - Font selection (if applicable on mobile)

## Impact

- **Affected specs**:
  - authentication (MODIFIED)
  - audio-player (MODIFIED)
  - favorites-management (MODIFIED)
  - search (NEW capability)
  - content-pages (NEW capability)
  - settings (MODIFIED)
  - bilibili-api (MODIFIED)

- **Affected code**:
  - `lib/features/search/` - Major enhancements
  - `lib/features/player/` - URL checking, quality selection
  - `lib/features/auth/` - Geetest, cookie refresh
  - `lib/features/favorites/` - Batch ops, filtering
  - `lib/features/home/` - Replace with music rank
  - NEW: `lib/features/history/`
  - NEW: `lib/features/later/`
  - NEW: `lib/features/follow/`
  - NEW: `lib/features/music_rank/`
  - NEW: `lib/features/user_profile/`

- **Breaking changes**: None (additive changes)

## Source Reference Mapping

| Flutter Feature | Source Location |
|-----------------|-----------------|
| Search history | `biu/src/store/search-history.ts` |
| Music rank page | `biu/src/pages/music-rank/` |
| History page | `biu/src/pages/history/` |
| Later page | `biu/src/pages/later/` |
| Follow list | `biu/src/pages/follow-list/` |
| URL validity check | `biu/src/common/utils/audio.ts:isUrlValid` |
| Geetest SDK | `biu/src/common/hooks/use-geetest.ts` |
| Cookie refresh | `biu/src/store/token.ts` |
| Batch favorites ops | `biu/src/service/fav-resource-*.ts` |
| Folder search/filter | `biu/src/pages/video-collection/favorites.tsx` |

## Success Criteria

1. Search defaults to "music only" (tids: 3) with toggle option
2. Search history persists and displays on focus
3. Music rank shows as homepage content
4. User can view watch history and later list
5. Player checks URL deadline before playback
6. User can select preferred audio quality
7. Geetest captcha works for password/SMS login
8. Favorites support search, sort, and batch operations

## Alignment Status Summary

| Module | Current | Target | Gap |
|--------|---------|--------|-----|
| Authentication | 85% | 98% | Geetest, cookie refresh |
| Audio Player | 80% | 95% | URL check, quality UI, rate UI |
| Search | 60% | 95% | History, pagination, music filter |
| Favorites | 70% | 90% | Batch ops, filter, play all |
| Content Pages | 10% | 90% | All missing pages |
| Settings | 55% | 75% | Display mode, menu hide |