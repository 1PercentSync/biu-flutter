# Implementation Tasks

## Agent Instructions
After completing each phase or major task:
1. Ensure code compiles: `flutter analyze`
2. Run tests: `flutter test`
3. Commit changes: `git commit -m "type(scope): description"`
4. Push to remote: `git push`

## Phase 1: Core Infrastructure ✅

### 1.1 Project Setup
- [x] 1.1.1 Update `pubspec.yaml` with required dependencies
  - flutter_riverpod, go_router, dio, shared_preferences, sqflite
  - just_audio, audio_service, cached_network_image
  - Reference: None (new file)
- [x] 1.1.2 Create directory structure under `lib/`
  - Create: core/, features/, shared/ directories
  - Reference: None (new structure)
- [x] 1.1.3 Configure `analysis_options.yaml` with strict linting
  - Reference: `biu/.eslintrc` (for linting philosophy)
- [x] 1.1.4 Set up app entry point `lib/main.dart` with ProviderScope
  - Reference: `biu/src/index.tsx`

### 1.2 Core Utilities
- [x] 1.2.1 Create `lib/core/constants/` with app constants
  - Audio quality levels, play modes, API base URLs
  - Reference: `biu/src/common/constants/`
- [x] 1.2.2 Create `lib/core/extensions/` with Dart extensions
  - String extensions, DateTime extensions
  - Reference: `biu/src/common/utils/str.ts`, `time.ts`
- [x] 1.2.3 Create `lib/core/errors/` with exception classes
  - BilibiliApiException, NetworkException, AuthException
  - Reference: `biu/src/service/request/response-interceptors.ts`
- [x] 1.2.4 Create `lib/core/utils/` with utility functions
  - URL formatting, number formatting
  - Reference: `biu/src/common/utils/`

### 1.3 Navigation
- [x] 1.3.1 Configure go_router in `lib/core/router/`
  - Define routes: /, /login, /search, /favorites, /profile, /settings
  - Reference: `biu/src/app.tsx` (React Router setup)
- [x] 1.3.2 Implement auth redirect guard
  - Redirect to /login if not authenticated for protected routes
  - Reference: Authentication flow in source

### 1.4 Local Storage
- [x] 1.4.1 Create storage abstraction in `lib/core/storage/`
  - Interface for key-value storage
  - Implementation using shared_preferences
- [x] 1.4.2 Create secure storage for sensitive data
  - Cookies, tokens using flutter_secure_storage
  - Reference: `biu/src/store/token.ts`

## Phase 2: Bilibili API Client ✅

### 2.1 HTTP Client
- [x] 2.1.1 Create Dio instance in `lib/core/network/`
  - Base configuration, timeouts, headers
  - Reference: `biu/src/service/request/index.ts`
- [x] 2.1.2 Create logging interceptor
  - Log requests and responses in debug mode
  - Reference: `biu/src/service/request/request-interceptors.ts`
- [x] 2.1.3 Create auth interceptor
  - Inject cookies and tokens
  - Reference: `biu/src/service/request/request-interceptors.ts`
- [x] 2.1.4 Create response interceptor
  - Parse Bilibili response format, handle error codes
  - Reference: `biu/src/service/request/response-interceptors.ts`

### 2.2 WBI Signature
- [x] 2.2.1 Implement WBI key fetch and cache
  - Fetch from nav API, cache with expiry
  - Reference: `biu/src/service/request/wbi-sign.ts`
- [x] 2.2.2 Implement WBI signature generation
  - MD5 hash of sorted params + mixin key
  - Reference: `biu/src/service/request/wbi-sign.ts`
- [x] 2.2.3 Create WBI request helper
  - Auto-sign requests that need WBI
  - Reference: `biu/electron/ipc/api/wbi.ts`

### 2.3 BUVID and Ticket
- [x] 2.3.1 Implement BUVID3 generation
  - Generate and persist BUVID3
  - Reference: `biu/electron/network/web-buvid.ts`
- [x] 2.3.2 Implement bili_ticket fetch
  - Fetch and cache with auto-refresh
  - Reference: `biu/electron/network/web-bili-ticket.ts`

### 2.4 API Services
- [x] 2.4.1 Create `lib/features/*/data/datasources/` structure
  - Remote data sources for each feature
- [x] 2.4.2 Implement video info API
  - `GET /x/web-interface/view`
  - Reference: `biu/src/service/web-interface-view.ts`
- [x] 2.4.3 Implement audio stream URL API
  - DASH URL for videos, audio URL for music
  - Reference: `biu/electron/ipc/api/dash-url.ts`, `audio-stream-url.ts`
- [x] 2.4.4 Implement search APIs
  - Search all, search by type
  - Reference: `biu/src/service/web-interface-search-*.ts`

## Phase 3: Authentication ✅

### 3.1 Auth State Management
- [x] 3.1.1 Create `lib/features/auth/` structure
  - domain/, data/, presentation/ folders
- [x] 3.1.2 Create User entity and repository interface
  - Reference: `biu/src/store/user.ts`
- [x] 3.1.3 Create AuthNotifier (Riverpod)
  - States: unauthenticated, authenticating, authenticated
  - Reference: `biu/src/store/user.ts`

### 3.2 QR Code Login
- [x] 3.2.1 Implement QR code generation API
  - Reference: `biu/src/service/passport-login-web-qrcode-generate.ts`
- [x] 3.2.2 Implement QR code polling API
  - Reference: `biu/src/service/passport-login-web-qrcode-poll.ts`
- [x] 3.2.3 Create QR login UI screen
  - QR display, status text, refresh button
  - Reference: `biu/src/layout/navbar/login/qrcode-login.tsx`

### 3.3 Password Login
- [x] 3.3.1 Implement RSA key fetch API
  - Reference: `biu/src/service/passport-login-web-key.ts`
- [x] 3.3.2 Implement RSA password encryption
  - Reference: `biu/src/layout/navbar/login/password-login.tsx`
- [x] 3.3.3 Implement password login API
  - Reference: `biu/src/service/passport-login-web-login-passport.ts`
- [x] 3.3.4 Create password login UI screen
  - Username, password fields, captcha handling
  - Note: GeeTest captcha integration not implemented (shows info dialog)
  - Reference: `biu/src/layout/navbar/login/password-login.tsx`

### 3.4 SMS Login
- [x] 3.4.1 Implement SMS send API
  - Reference: `biu/src/service/passport-login-web-sms-send.ts`
- [x] 3.4.2 Implement SMS login API
  - Reference: `biu/src/service/passport-login-web-login-sms.ts`
- [x] 3.4.3 Create SMS login UI screen
  - Phone input, code input, country selector
  - Note: GeeTest captcha integration not implemented (shows info dialog)
  - Reference: `biu/src/layout/navbar/login/code-login.tsx`

### 3.5 Session Management
- [x] 3.5.1 Implement session validation
  - Check cookie validity on app start
  - Reference: `biu/src/service/passport-login-web-cookie-info.ts`
- [x] 3.5.2 Implement session refresh
  - Reference: `biu/src/service/passport-login-web-cookie-refresh.ts`
- [x] 3.5.3 Implement logout
  - Clear all stored credentials
  - Reference: `biu/src/service/passport-login-exit.ts`

## Phase 4: Audio Player ✅

### 4.1 Player Core
- [x] 4.1.1 Create `lib/features/player/` structure
- [x] 4.1.2 Create PlayItem entity
  - Mirror PlayData from source
  - Reference: `biu/src/store/play-list.ts` (PlayData interface)
- [x] 4.1.3 Create AudioPlayerService
  - Wrapper around just_audio
  - Reference: `biu/src/store/play-list.ts` (audio element handling)
- [x] 4.1.4 Configure background playback for iOS
  - Audio session, background modes
  - Reference: just_audio documentation

### 4.2 Playlist Management
- [x] 4.2.1 Create PlaylistNotifier
  - List state, current index, play modes
  - Reference: `biu/src/store/play-list.ts`
- [x] 4.2.2 Implement add/remove/clear operations
  - Reference: `biu/src/store/play-list.ts` (play, del, clear methods)
- [x] 4.2.3 Implement play mode switching
  - Sequential, Loop, Single, Shuffle
  - Reference: `biu/src/store/play-list.ts` (PlayMode enum)
- [x] 4.2.4 Implement next/prev navigation
  - Handle shuffle with page order option
  - Reference: `biu/src/store/play-list.ts` (next, prev methods)

### 4.3 Media Session
- [x] 4.3.1 Configure audio_service for media controls
  - Now playing info, playback controls
  - Reference: `biu/src/store/play-list.ts` (updateMediaSession)
- [x] 4.3.2 Handle media button events
  - Play, pause, next, previous
  - Reference: `biu/src/store/play-list.ts` (mediaSession handlers)

### 4.4 Playlist Persistence
- [x] 4.4.1 Implement playlist serialization
  - Save/load from local storage
  - Reference: `biu/src/store/play-list.ts` (persist middleware)
- [x] 4.4.2 Implement progress persistence
  - Save current position periodically
  - Reference: `biu/src/store/play-progress.ts`

## Phase 5: User Interface ✅

### 5.1 Theme and Styles
- [x] 5.1.1 Create ThemeData configuration
  - Dark theme matching source colors
  - Reference: `biu/shared/settings/app-settings.ts` (colors)
- [x] 5.1.2 Create custom color scheme
  - Background, content background, primary
  - Reference: `biu/src/components/theme/`

### 5.2 App Shell
- [x] 5.2.1 Create main layout scaffold
  - Bottom navigation, content area
  - Reference: `biu/src/layout/index.tsx`
- [x] 5.2.2 Create bottom navigation bar
  - Home, Search, Favorites, Profile tabs
  - Reference: `biu/src/layout/side/default-menu/`

### 5.3 Playbar
- [x] 5.3.1 Create mini playbar widget
  - Cover, title, play/pause button
  - Reference: `biu/src/layout/playbar/left/`
- [x] 5.3.2 Create full player screen
  - Large cover, controls, progress, playlist
  - Reference: `biu/src/layout/playbar/`
- [x] 5.3.3 Implement expand/collapse animation
  - Gesture-based transition
  - Reference: `biu/src/layout/playbar/`

### 5.4 Common Widgets
- [x] 5.4.1 Create TrackListItem widget
  - Cover, title, author, duration
  - Reference: `biu/src/components/music-list-item/`
- [x] 5.4.2 Create VideoCard widget
  - Grid/card layout for videos
  - Reference: `biu/src/components/mv-card/`
- [x] 5.4.3 Create CachedImage widget
  - Loading placeholder, error fallback
  - Reference: `biu/src/components/image/`
- [x] 5.4.4 Create EmptyState widget
  - Illustration and message
  - Reference: `biu/src/components/empty/`

### 5.5 Screens
- [x] 5.5.1 Create Home screen
  - Featured content, recommendations
  - Reference: `biu/src/pages/` (home related)
- [x] 5.5.2 Create Search screen
  - Search input, history, results
  - Reference: `biu/src/layout/navbar/search/`
- [x] 5.5.3 Create Profile screen
  - User info, menu options
  - Reference: `biu/src/layout/navbar/user/`
- [x] 5.5.4 Create Login screen (tabbed)
  - QR, Password, SMS tabs
  - Reference: `biu/src/layout/navbar/login/`

## Phase 6: Favorites

### 6.1 Favorites Data Layer
- [ ] 6.1.1 Create FavoritesFolder entity
- [ ] 6.1.2 Create FavoritesRepository interface
- [ ] 6.1.3 Implement folder list APIs
  - Reference: `biu/src/service/fav-folder-*.ts`
- [ ] 6.1.4 Implement resource APIs
  - Reference: `biu/src/service/fav-resource*.ts`

### 6.2 Favorites UI
- [ ] 6.2.1 Create Favorites screen
  - Created and Collected tabs
  - Reference: `biu/src/layout/side/collection/`
- [ ] 6.2.2 Create Folder detail screen
  - List items with actions
- [ ] 6.2.3 Create Folder edit dialog
  - Reference: `biu/src/components/favorites-edit-modal/`
- [ ] 6.2.4 Create Folder select sheet
  - For adding videos to favorites
  - Reference: `biu/src/components/favorites-select-modal/`

## Phase 7: Settings

### 7.1 Settings Data
- [ ] 7.1.1 Create Settings entity
  - Reference: `biu/shared/settings/app-settings.ts`
- [ ] 7.1.2 Create SettingsNotifier
  - Reference: `biu/src/store/settings.ts`
- [ ] 7.1.3 Implement settings persistence
  - Reference: `biu/src/store/settings.ts`

### 7.2 Settings UI
- [ ] 7.2.1 Create Settings screen
  - Grouped settings sections
- [ ] 7.2.2 Implement audio quality picker
- [ ] 7.2.3 Implement theme color picker
  - Reference: `biu/src/components/color-picker/`
- [ ] 7.2.4 Implement account section
  - User info, logout button
- [ ] 7.2.5 Create About screen
  - Version info, licenses

## Phase 8: Testing and Polish

### 8.1 Testing
- [ ] 8.1.1 Write unit tests for core utilities
- [ ] 8.1.2 Write unit tests for API services
- [ ] 8.1.3 Write widget tests for common widgets
- [ ] 8.1.4 Write integration tests for auth flow

### 8.2 Platform Configuration
- [ ] 8.2.1 Configure iOS background audio entitlements
- [ ] 8.2.2 Configure iOS App Transport Security
- [ ] 8.2.3 Add app icons and splash screen
- [ ] 8.2.4 Configure Windows build (development)

### 8.3 Final Polish
- [ ] 8.3.1 Add loading states to all async operations
- [ ] 8.3.2 Add error handling and retry UI
- [ ] 8.3.3 Optimize list performance
- [ ] 8.3.4 Final UI polish and animations
