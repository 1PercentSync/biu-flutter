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

- [ ] 1.1.1 `lib/core/constants/response_code.dart`
  - Source: `biu/src/common/constants/response-code.ts`

- [ ] 1.1.2 `lib/core/constants/audio.dart`
  - Source: `biu/src/common/constants/audio.tsx`

- [ ] 1.1.3 `lib/core/constants/api.dart`
  - Source: Flutter-only (document as such)

- [ ] 1.1.4 `lib/core/constants/app.dart`
  - Source: Flutter-only (document as such)

### 1.2 Utils

- [ ] 1.2.1 `lib/core/utils/color_utils.dart`
  - Source: `biu/src/common/utils/color.ts`

- [ ] 1.2.2 `lib/core/utils/number_utils.dart`
  - Source: `biu/src/common/utils/number.ts`

- [ ] 1.2.3 `lib/core/utils/format_utils.dart`
  - Source: `biu/src/common/utils/number.ts` (split)

- [ ] 1.2.4 `lib/core/utils/url_utils.dart`
  - Source: `biu/src/common/utils/url.ts` + `biu/src/common/utils/audio.ts#isUrlValid`

- [ ] 1.2.5 `lib/core/utils/rsa_utils.dart`
  - Source: `biu/src/common/utils/cookie.ts` (RSA encryption part)

- [ ] 1.2.6 `lib/core/utils/debouncer.dart`
  - Source: Flutter-only (document as such)

### 1.3 Extensions

- [ ] 1.3.1 `lib/core/extensions/string_extensions.dart`
  - Source: `biu/src/common/utils/str.ts` + `biu/src/common/utils/url.ts`

- [ ] 1.3.2 `lib/core/extensions/datetime_extensions.dart`
  - Source: `biu/src/common/utils/time.ts`

- [ ] 1.3.3 `lib/core/extensions/duration_extensions.dart`
  - Source: `biu/src/common/utils/time.ts`

### 1.4 Errors

- [ ] 1.4.1 `lib/core/errors/app_exception.dart`
  - Source: Flutter-only (document as such)

### 1.5 Network Layer

- [ ] 1.5.1 `lib/core/network/dio_client.dart`
  - Source: `biu/src/service/request/index.ts`

- [ ] 1.5.2 `lib/core/network/api/base_api_service.dart`
  - Source: Flutter-only (document as such)

- [ ] 1.5.3 `lib/core/network/interceptors/auth_interceptor.dart`
  - Source: `biu/src/service/request/request-interceptors.ts`

- [ ] 1.5.4 `lib/core/network/interceptors/response_interceptor.dart`
  - Source: `biu/src/service/request/response-interceptors.ts`

- [ ] 1.5.5 `lib/core/network/interceptors/logging_interceptor.dart`
  - Source: `biu/src/service/request/response-interceptors.ts` (logging part)

- [ ] 1.5.6 `lib/core/network/wbi/wbi_sign.dart`
  - Source: `biu/src/service/request/wbi-sign.ts`

- [ ] 1.5.7 `lib/core/network/buvid/buvid_service.dart`
  - Source: `biu/src/service/web-buvid.ts`

- [ ] 1.5.8 `lib/core/network/ticket/bili_ticket_service.dart`
  - Source: `biu/src/service/web-bili-ticket.ts`

### 1.6 Router

- [ ] 1.6.1 `lib/core/router/routes.dart`
  - Source: `biu/src/routes.tsx`

- [ ] 1.6.2 `lib/core/router/app_router.dart`
  - Source: `biu/src/app.tsx` + `biu/src/layout/index.tsx`

- [ ] 1.6.3 `lib/core/router/auth_guard.dart`
  - Source: Flutter-only (document as such)

### 1.7 Storage

- [ ] 1.7.1 `lib/core/storage/storage_service.dart`
  - Source: Flutter-only (Zustand persist -> SharedPreferences)

- [ ] 1.7.2 `lib/core/storage/secure_storage_service.dart`
  - Source: Flutter-only (document as such)

---

## Phase 2: Feature Layer Documentation (Planned)

To be expanded after Phase 1 completion:
- Authentication datasources and providers
- Favorites datasources and providers
- Player services and providers
- Search datasources and providers
- History/Later/Follow datasources
- User profile datasources
- Settings providers

---

## Phase 3: Code Quality Issues (Discovered)

Document code quality issues as they are discovered during documentation:

### Potential Improvements
- [ ] (To be filled during Phase 1 review)

---

## Breaking Changes Log

Document any changes that affect upper layers:

(None yet - Phase 1-2 are documentation only)
