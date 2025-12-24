# Design Decisions - Flutter Alignment

## Context

The Flutter project was migrated from an Electron + React application. This document captures technical decisions for aligning the Flutter implementation with source project behavior.

## Goals / Non-Goals

### Goals
- Achieve feature parity with source Electron app
- Maintain clean architecture and code organization
- Ensure iOS compatibility as primary target
- Keep implementation simple and maintainable

### Non-Goals
- 100% pixel-perfect UI matching (mobile adaptation allowed)
- Desktop-specific features (system tray, mini window)
- Download functionality (iOS sandbox limitations)
- Video playback (audio focus for Phase 1)

---

## Key Decisions

### D1: Geetest SDK Integration

**Decision**: Use WebView-based Geetest integration instead of native SDK

**Rationale**:
- Geetest official Flutter SDK has limited documentation
- WebView approach mirrors how source project loads the SDK dynamically
- More maintainable and easier to debug
- Works consistently across iOS and Android

**Implementation**:
```dart
// Use flutter_inappwebview to load Geetest challenge
// Intercept callback via JavaScript channel
class GeetestDialog extends StatefulWidget {
  // Load Geetest challenge URL in WebView
  // Capture result via JS interface
}
```

**Reference**: `biu/src/common/utils/geetest.ts` loads SDK via dynamic script injection

**Alternatives Considered**:
- Native Geetest SDK: Limited Flutter support, complex integration
- Skip Geetest entirely: Would break password/SMS login in many cases

---

### D2: URL Validity Checking Strategy

**Decision**: Pre-validate URL before playback, not just on exception

**Rationale**:
- Source project checks `deadline` parameter proactively
- Reduces failed playback attempts
- Better user experience (no playback start then fail)
- Audio URLs typically valid for ~2 hours

**Implementation**:
```dart
bool isUrlValid(String? url) {
  if (url == null) return false;
  final deadline = Uri.parse(url).queryParameters['deadline'];
  if (deadline == null) return true; // No deadline = assume valid
  return DateTime.now().secondsSinceEpoch < int.parse(deadline);
}
```

**Call Sites**:
1. Before setting audio URL in `_ensureAudioUrlValid()`
2. Before resuming playback on app foreground
3. Periodically during long playback sessions

---

### D3: Search History Storage

**Decision**: Use SharedPreferences with JSON serialization

**Rationale**:
- Matches source project's localStorage approach
- Simple key-value storage sufficient for history
- No need for SQLite complexity for this use case
- Easy to migrate or clear

**Storage Format**:
```json
{
  "search_history": [
    {"value": "周杰伦", "timestamp": 1703123456},
    {"value": "林俊杰", "timestamp": 1703123400}
  ]
}
```

**Limits**:
- Max 50 items (prevent unbounded growth)
- FIFO replacement when limit reached

---

### D4: Audio Quality Selection Architecture

**Decision**: Centralize quality preference in SettingsNotifier, apply in audio fetch

**Rationale**:
- Single source of truth for user preference
- Decoupled from player logic
- Easy to persist and restore
- Matches source project's store-based approach

**Data Flow**:
```
User selects quality in Settings
    ↓
SettingsNotifier.setAudioQuality(quality)
    ↓
Persisted to SharedPreferences
    ↓
Audio fetch reads from settingsProvider
    ↓
selectAudioByQuality(audioList, userQuality)
    ↓
Player receives selected audio URL
```

**Quality Mapping**:
| User Setting | Selection Logic |
|--------------|-----------------|
| auto | FLAC > Dolby > highest bitrate |
| lossless | FLAC only, fallback to Dolby |
| high | Highest bitrate standard audio |
| medium | Middle bitrate from sorted list |
| low | Lowest bitrate |

---

### D5: Content Pages Architecture

**Decision**: Create separate feature modules for each content page

**Rationale**:
- Follows existing feature-first architecture
- Clear separation of concerns
- Independent testing and maintenance
- Consistent with existing favorites, search, etc.

**Directory Structure**:
```
lib/features/
├── music_rank/
│   ├── data/
│   │   ├── datasources/
│   │   └── models/
│   ├── domain/
│   │   └── entities/
│   └── presentation/
│       ├── providers/
│       ├── screens/
│       └── widgets/
├── history/
│   └── (same structure)
├── later/
│   └── (same structure)
├── follow/
│   └── (same structure)
└── artist_rank/
    └── (same structure)
```

---

### D6: Navigation Integration for New Pages

**Decision**: Add new pages to bottom navigation with conditional visibility

**Rationale**:
- Mobile UX requires easy access to main features
- 5 tabs maximum for comfortable thumb reach
- Some features require authentication

**Tab Structure**:
```
Home (Music Rank) | Search | Favorites | History/Later | Profile
```

**Conditional Routes**:
- Favorites: Requires auth (redirect to login if not)
- History: Requires auth
- Profile: Shows login prompt if not authenticated

---

### D7: Batch Operations UI Pattern

**Decision**: Use long-press selection mode with bottom action bar

**Rationale**:
- Standard mobile pattern (Gmail, Photos, etc.)
- Doesn't clutter normal view
- Supports multi-select naturally
- Familiar to users

**Implementation**:
```dart
class FolderDetailScreen extends StatefulWidget {
  bool isSelectionMode = false;
  Set<String> selectedIds = {};

  // Long press item -> enter selection mode
  // Tap item in selection mode -> toggle selection
  // Bottom bar shows: Delete | Move | Copy | Cancel
}
```

---

## Risks / Trade-offs

### R1: Geetest WebView Approach
- **Risk**: May break if Geetest changes their web SDK
- **Mitigation**: Monitor for changes, have fallback info dialog

### R2: URL Deadline Parsing
- **Risk**: Deadline format might vary across API responses
- **Mitigation**: Graceful fallback (treat as valid if parse fails)

### R3: Feature Creep in Alignment
- **Risk**: Scope may expand during implementation
- **Mitigation**: Strict priority enforcement, P2 items are optional

---

## Migration Plan

### Phase A (Week 1-2): Critical Fixes
1. Search music filter + history
2. URL validity checking
3. Audio quality selection

### Phase B (Week 3-4): Content Pages
1. Music rank (replace home)
2. History + Later
3. Follow list

### Phase C (Week 5+): Enhancements
1. Favorites batch operations
2. Settings enhancements
3. Polish and testing

**Rollback Strategy**: Each phase is independent; can release after Phase A if needed.

---

## Open Questions

1. **Q: Should we implement Geetest before or after other auth improvements?**
   - Recommended: Implement early as it blocks password/SMS login for some users

2. **Q: Should music rank completely replace home, or be a tab within home?**
   - Recommended: Complete replacement, matching source behavior

3. **Q: How to handle API rate limiting in batch operations?**
   - Implement: Sequential operations with delay, not parallel

4. **Q: Should search history sync across devices?**
   - Decision: No, local only (matches source behavior, simplifies implementation)
