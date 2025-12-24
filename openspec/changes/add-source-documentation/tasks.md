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

### Documented Simplifications

| Module | Missing Feature | Reason |
|--------|-----------------|--------|
| auth | Country list API | Hardcoded 3 common regions (acceptable) |
| search | article/photo/live types | Music player doesn't need them |

---

## Breaking Changes Log

Document any changes that affect upper layers:

(None yet - Phase 1-2 are documentation only)
