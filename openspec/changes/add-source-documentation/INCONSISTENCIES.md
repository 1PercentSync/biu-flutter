# Discovered Inconsistencies

This document tracks inconsistencies found between Flutter and Electron implementations.

## Fixed

| File | Issue | Source Reference | Fix Applied |
|------|-------|------------------|-------------|
| `core/utils/number_utils.dart` | `formatCompact` used "K" suffix for 1000-9999 range | `biu/src/common/utils/number.ts` uses zh-CN Intl format | Changed to display raw number for <10000, matching source |
| `core/utils/url_utils.dart` | `buildVideoUrl` missing pageIndex support | `biu/src/common/utils/url.ts#getBiliVideoLink` | Added optional `pageIndex` parameter |
| `core/utils/format_utils.dart` | Duplicate of `number_utils.dart`, never used | N/A | **Deleted** - restored 1:1 mapping with `number.ts` |

## Pending Review

### Code Quality Issues

| File | Issue | Recommendation | Status |
|------|-------|----------------|--------|
| ~~`format_utils.dart` + `number_utils.dart`~~ | ~~Duplicate logic~~ | ~~Consolidate~~ | ✅ Fixed: deleted format_utils.dart |
| ~~`video_card.dart`, `musician_card.dart`, `folder_detail_screen.dart`~~ | ~~Private `_formatCount` duplicates~~ | ~~Use `NumberUtils.formatCompact`~~ | ✅ Fixed: replaced with NumberUtils |

### File Correspondence Issues (1:1 Mapping Violations)

Deviations from 1:1 mapping should be **justified by Flutter/Dart conventions**.

| Source | Target(s) | Status | Justification |
|--------|-----------|--------|---------------|
| `common/utils/number.ts` | `number_utils.dart` ~~+ `format_utils.dart`~~ | ✅ Fixed | Deleted duplicate, now 1:1 |
| `common/utils/time.ts` | `datetime_extensions.dart` + `duration_extensions.dart` | ✅ Justified | Dart extension pattern: separate by type (DateTime vs Duration) |
| `common/utils/str.ts` | `string_extensions.dart` | ✅ 1:1 | Direct mapping with Dart extension pattern |
| `common/utils/url.ts` | `url_utils.dart` | ✅ 1:1 | Direct mapping |
| `common/utils/audio.ts` | Partial in `url_utils.dart`, main logic in features | ✅ Justified | Clean Architecture: utils for pure functions, features for stateful logic |
| `common/utils/cookie.ts` | `rsa_utils.dart` + `cookie_refresh_service.dart` | ✅ Justified | Split by concern: crypto utils vs. service logic |

### Layer Hierarchy Issues

| Source | Target | Issue | Status |
|--------|--------|-------|--------|
| `biliRequest` in `request/index.ts` | ~~Missing~~ `biliDio` in `dio_client.dart` | ~~No Dio instance for www.bilibili.com~~ | ✅ Fixed: Added `biliDio` getter |

### Functional Boundary Issues

| Module | Missing Feature | Source Reference | Status |
|--------|-----------------|------------------|--------|
| ~~`auth`~~ | ~~Country list API for SMS login~~ | `biu/src/service/passport-login-web-country.ts` | ✅ Fixed: Added getCountryList API |
| `search` | Article/Photo/Live search types | `biu/src/service/web-interface-search-type.ts` | ⚠️ Simplified: Music player only needs video/user search |

### Behavioral Differences

| File | Issue | Source Reference | Status |
|------|-------|------------------|--------|
| `playlist_notifier.dart` | `addToNext` didn't move existing item to after current | `biu/src/store/play-list.ts:678-690` | ✅ Fixed: Now moves existing item |
| `playlist_notifier.dart` | `next()` Random mode uses different logic | `biu/src/store/play-list.ts:631-637` | ⚠️ Acceptable: Source shuffles every time, Flutter uses direct random (simpler, equivalent behavior) |
| `later_remote_datasource.dart` | `addToWatchLater` and `removeFromWatchLater` missing `useCSRF: true` | `biu/src/service/history-toview-*.ts` | ✅ Fixed: Added CSRF option |

## Breaking Changes

Changes that may affect upper layer code:

| Change | Affected Upper Layer | Action Required |
|--------|---------------------|-----------------|
| `buildVideoUrl` now accepts `pageIndex` | Call sites may want to pass pageIndex | No action required (optional param) |
| `DioClient.biliDio` added | Services needing www.bilibili.com can now use this | Use for cookie refresh and audio song info |

## Notes

- All fixes should maintain backwards compatibility where possible
- Breaking changes require discussion before implementation
- Upper layer impacts should be documented for each fix
