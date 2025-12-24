# Technical Design: Biu Flutter Migration

## Context

### Background
Biu is an Electron-based desktop music player that uses Bilibili's public APIs. The application needs to be migrated to Flutter to support iOS (primary target) while maintaining Windows support for development.

### Stakeholders
- End users: Bilibili content consumers who want a mobile music player
- Developers: Need maintainable, testable codebase

### Constraints
- Must work without FFmpeg on iOS (no audio extraction from video)
- Must handle Bilibili's anti-scraping measures (WBI, BUVID, captcha)
- Must support background audio playback on iOS
- Cannot use commercial dependencies (PolyForm Noncommercial license)

## Goals / Non-Goals

### Goals
- Provide feature parity for core music playback on iOS
- Create maintainable, well-structured Flutter codebase
- Enable efficient development with proper state management
- Support offline capability for basic features

### Non-Goals
- Video playback (audio focus only for Phase 1)
- Desktop-specific features (system tray, mini player window)
- Download manager with video processing
- Linux/Android support in Phase 1

## Decisions

### Decision 1: State Management - Riverpod

**Choice**: flutter_riverpod

**Alternatives Considered**:
1. **Bloc** - More boilerplate, event-driven pattern may be overkill
2. **Provider** - Less type-safe, Riverpod is its evolution
3. **GetX** - Less structured, can lead to spaghetti code
4. **MobX** - Less popular in Flutter ecosystem

**Rationale**:
- Type-safe and compile-time checked
- Built-in dependency injection
- Excellent DevTools support
- Easy testing with override capabilities
- Good documentation and community

### Decision 2: HTTP Client - Dio

**Choice**: dio with interceptors

**Alternatives Considered**:
1. **http** - Too basic, no interceptor support
2. **Chopper** - More setup, retrofit-style may be overkill

**Rationale**:
- Interceptor support essential for WBI signing, auth injection
- FormData support for multipart requests
- Request/response transformers
- Cancel token support for cleanup

### Decision 3: Audio Playback - just_audio

**Choice**: just_audio + audio_service

**Alternatives Considered**:
1. **audioplayers** - Less feature-rich, simpler but limited
2. **assets_audio_player** - Less maintained

**Rationale**:
- Excellent streaming support
- Background playback built-in
- Gapless playback for playlists
- Active maintenance and good documentation
- audio_service integration for media controls

### Decision 4: Navigation - go_router

**Choice**: go_router

**Alternatives Considered**:
1. **Navigator 2.0 directly** - Complex, verbose
2. **auto_route** - More magic, code generation overhead
3. **beamer** - Similar to go_router but less popular

**Rationale**:
- Declarative routing
- Deep linking support
- Redirect guards for auth
- ShellRoute for persistent layouts
- Official package from Flutter team

### Decision 5: Local Storage - Layered Approach

**Choice**:
- shared_preferences for simple settings
- sqflite for structured data (playlist, history)
- flutter_secure_storage for credentials

**Alternatives Considered**:
1. **Hive** - Good but overkill for simple needs
2. **Isar** - Newer, less battle-tested
3. **drift** - Excellent but adds complexity

**Rationale**:
- Different storage needs require different solutions
- shared_preferences is simple and sufficient for settings
- sqflite provides SQL queries for complex playlist operations
- Secure storage required for session cookies

### Decision 6: Architecture - Clean Architecture (Simplified)

**Choice**: 3-layer clean architecture per feature

```
feature/
├── data/           # API, local sources, repositories
├── domain/         # Entities, use cases (optional), repository interfaces
└── presentation/   # Screens, widgets, providers
```

**Alternatives Considered**:
1. **Full Clean Architecture** - Too many layers, excessive abstraction
2. **MVC** - Doesn't fit Flutter well
3. **MVVM** - Similar outcome, different naming

**Rationale**:
- Clear separation of concerns
- Testable layers
- Not over-engineered for a medium-sized app
- Familiar to most Flutter developers

### Decision 7: Cookie Management

**Choice**: dio_cookie_manager + cookie_jar

**Rationale**:
- Automatic cookie persistence
- Compatible with Dio interceptors
- Handles Bilibili's cookie requirements
- Supports secure storage for sensitive cookies

### Decision 8: Image Caching

**Choice**: cached_network_image

**Alternatives Considered**:
1. **extended_image** - More features but heavier
2. **Custom solution** - Not worth the effort

**Rationale**:
- Efficient memory management
- Placeholder and error widget support
- LRU cache with configurable size
- Well-maintained and popular

## Risks / Trade-offs

### Risk 1: Bilibili API Changes
- **Risk**: Bilibili may change API signatures or add new protection
- **Mitigation**: Abstract API layer, monitor bilibili-API-collect repo
- **Trade-off**: May need to update frequently

### Risk 2: iOS Background Audio Limitations
- **Risk**: iOS may kill background process
- **Mitigation**: Proper audio session configuration, handle interruptions
- **Trade-off**: Accept some limitations vs native app

### Risk 3: WBI Signature Complexity
- **Risk**: WBI algorithm may change, breaking authentication
- **Mitigation**: Isolate WBI logic, add logging for debugging
- **Trade-off**: Depends on reverse-engineering accuracy

### Risk 4: App Store Rejection
- **Risk**: Apple may reject for accessing third-party content
- **Mitigation**: Frame as a Bilibili companion app, don't infringe trademarks
- **Trade-off**: May need to distribute outside App Store

## Migration Plan

### Phase 1: Foundation (Weeks 1-2)
- Set up project structure
- Implement core infrastructure
- Create HTTP client with interceptors

### Phase 2: Authentication (Weeks 3-4)
- Implement QR code login
- Implement password/SMS login
- Set up session management

### Phase 3: Playback (Weeks 5-6)
- Implement audio player service
- Create playlist management
- Add media session integration

### Phase 4: UI (Weeks 7-8)
- Create app shell and navigation
- Implement playbar
- Build common widgets

### Phase 5: Features (Weeks 9-10)
- Implement favorites management
- Create search functionality
- Build settings screen

### Phase 6: Polish (Weeks 11-12)
- Testing
- Performance optimization
- iOS configuration and build

### Rollback Strategy
- Each phase is independently deployable
- Feature flags for incomplete features
- Git tags at each phase completion

## Open Questions

### Q1: Should we support Android?
- **Current Decision**: No, iOS focus for Phase 1
- **Revisit When**: After successful iOS launch

### Q2: How to handle VIP-only content?
- **Current Decision**: Show quality limitations, encourage login
- **Revisit When**: User feedback received

### Q3: Offline mode scope?
- **Current Decision**: Persist playlist only, no offline caching
- **Revisit When**: Phase 2 planning

### Q4: Analytics/crash reporting?
- **Current Decision**: Defer to later phase
- **Revisit When**: App is stable

## Source Code Mapping

| Source (Electron/React) | Target (Flutter) |
|------------------------|------------------|
| `biu/src/store/` | `lib/features/*/presentation/providers/` |
| `biu/src/service/` | `lib/features/*/data/datasources/` |
| `biu/src/components/` | `lib/shared/widgets/` |
| `biu/src/layout/` | `lib/shared/layout/` + feature screens |
| `biu/src/pages/` | `lib/features/*/presentation/screens/` |
| `biu/electron/ipc/` | `lib/core/network/` + feature services |
| `biu/shared/` | `lib/core/constants/` |
