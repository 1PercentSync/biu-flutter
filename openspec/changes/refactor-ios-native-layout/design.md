# Design: iOS-Native Layout Refactor

## Context

### Background
The Biu-Flutter project is migrating an Electron desktop app to Flutter, targeting iOS as the primary platform. The current Flutter implementation follows Material Design patterns, which feel out of place on iOS. A prototype has been approved that demonstrates the desired iOS-native experience.

### Stakeholders
- End users on iOS devices
- Developers maintaining the Flutter codebase
- Future contributors implementing new features

### Constraints
1. **Must use existing theme system** - Colors come from `settingsNotifierProvider` (primaryColor, backgroundColor)
2. **Must support all iPhone sizes** - From iPhone SE to iPhone 14 Pro Max
3. **Must not break existing functionality** - Navigation, playback, settings must continue working
4. **Performance sensitive** - Backdrop blur is GPU-intensive, must be optimized

## Goals / Non-Goals

### Goals
1. Implement iOS-native visual style matching the prototype
2. Create reusable frosted glass components for future use
3. Ensure responsive design across all iPhone screen sizes
4. Maintain full compatibility with existing theme/settings system
5. Provide smooth 60fps animations and transitions

### Non-Goals
1. **Not changing color defaults** - Keep existing green (#17C964) as default primary
2. **Not adding new settings** - Use existing primaryColor, backgroundColor, borderRadius
3. **Not supporting iPad** - This change focuses on iPhone form factors
4. **Not implementing Android-specific adaptations** - iOS is the target platform

## Decisions

### Decision 1: Stack-based Layout Architecture

**What**: Change `MainShell` from `Column` to `Stack` layout.

**Why**:
- Enables floating mini player above navigation
- Allows independent positioning of glass backdrop layers
- Matches iOS system apps (Music, Podcasts) layout patterns

**Implementation**:
```dart
Stack(
  children: [
    // 1. Main content (with bottom padding for floating elements)
    Positioned.fill(child: _content),

    // 2. Bottom glass backdrop layer
    Positioned(bottom: 0, child: _bottomGlassBackdrop),

    // 3. Floating mini player
    Positioned(bottom: navHeight + safeBottom + 8, child: _miniPlayer),

    // 4. Bottom navigation (transparent, on top of glass)
    Positioned(bottom: 0, child: _bottomNav),
  ],
)
```

**Alternatives Considered**:
- Keep Column with negative margins → Rejected: hacky, poor semantics
- Use CustomMultiChildLayout → Rejected: over-engineering

### Decision 2: Computed Frosted Glass Colors

**What**: Derive glass background colors from user's `backgroundColor` setting.

**Why**:
- Respects user theme customization
- No new settings required
- Consistent with iOS system behavior

**Implementation**:
```dart
class GlassStyles {
  /// Standard glass background (88% opacity of background color)
  static Color glassBackground(Color backgroundColor) {
    return backgroundColor.withOpacity(0.88);
  }

  /// Elevated glass background (85% opacity, slightly lighter)
  static Color glassBackgroundElevated(Color backgroundColor) {
    final hsl = HSLColor.fromColor(backgroundColor);
    final lighter = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0));
    return lighter.toColor().withOpacity(0.85);
  }
}
```

**Alternatives Considered**:
- Hardcode glass colors → Rejected: breaks theme customization
- Add new glass color settings → Rejected: unnecessary complexity

### Decision 3: MediaQuery for All Safe Areas

**What**: Always use `MediaQuery.of(context).padding` for safe areas.

**Why**:
- Automatically adapts to all iPhone models
- Handles notch, Dynamic Island, home indicator
- Future-proof for new device types

**Implementation**:
```dart
Widget build(BuildContext context) {
  final padding = MediaQuery.of(context).padding;
  final topSafe = padding.top;      // 0-59px depending on device
  final bottomSafe = padding.bottom; // 0-34px depending on device

  // Use these values for positioning, never hardcode
}
```

**Alternatives Considered**:
- Device detection + lookup table → Rejected: brittle, not future-proof
- Fixed values with platform check → Rejected: doesn't handle all devices

### Decision 4: LayoutBuilder-based Tab Font Sizing

**What**: Auto-calculate tab header font size based on available width.

**Why**:
- Prototype shows font range 16-28px with dynamic sizing
- Different iPhone widths need different font sizes
- Ensures tabs always fit without overflow

**Implementation**:
```dart
double calculateOptimalFontSize({
  required double containerWidth,
  required List<String> tabs,
  double minSize = 16,
  double maxSize = 28,
  double minGap = 10,
}) {
  // Binary search for largest font that fits
  for (double size = maxSize; size >= minSize; size -= 1) {
    final totalWidth = tabs.fold(0.0, (sum, tab) {
      return sum + _measureText(tab, size) + minGap;
    }) - minGap;

    if (totalWidth <= containerWidth) return size;
  }
  return minSize;
}
```

**Alternatives Considered**:
- FittedBox → Rejected: doesn't maintain spacing between tabs
- Fixed small font → Rejected: wastes space on larger devices

### Decision 5: Separate Glass Components

**What**: Create dedicated glass widget files instead of inline implementations.

**Why**:
- Reusable across app (future: search bar, modals, etc.)
- Encapsulates BackdropFilter complexity
- Easier to test and maintain

**File Structure**:
```
shared/widgets/glass/
├── frosted_glass.dart      # Base backdrop blur container
├── glass_styles.dart       # Color computation utilities
└── glass_bottom_nav.dart   # iOS-style navigation widget
```

## Risks / Trade-offs

### Risk 1: BackdropFilter Performance
**Risk**: Multiple backdrop filters may cause frame drops on older devices.
**Mitigation**:
- Limit to 2 glass layers (top header, bottom nav area)
- Use `ClipRect` to constrain blur area
- Test on iPhone SE (lowest performance target)

### Risk 2: Breaking Existing Navigation
**Risk**: Stack-based layout may affect GoRouter behavior.
**Mitigation**:
- MainShell still wraps child from GoRouter
- Navigation logic unchanged, only visual presentation changes
- Thorough testing of all navigation paths

### Risk 3: Content Padding Calculation
**Risk**: Incorrect padding may cause content to be hidden behind floating elements.
**Mitigation**:
- Calculate padding dynamically: `navHeight + safeBottom + playerHeight + margins`
- Expose padding values for child screens that need custom handling
- Add visual debugging option during development

## Migration Plan

### Phase 1: Foundation (No Visual Changes)
1. Add layout constants to `AppTheme`
2. Create `GlassStyles` utility class
3. Create `FrostedGlass` base component

### Phase 2: Bottom Section Refactor
1. Create `GlassBottomNav` component
2. Refactor `MiniPlaybar` with glass styling
3. Update `MainShell` to Stack layout

### Phase 3: Home Screen Refactor
1. Create `AdaptiveTabHeader` component
2. Implement PageView for tab content
3. Add top glass backdrop
4. Connect tab header with PageView

### Phase 4: Integration & Polish
1. Update `PlaybarScaffold` for non-shell routes
2. Test all navigation flows
3. Performance optimization
4. Edge case handling

### Rollback Plan
All changes are isolated to specific files. To rollback:
1. Revert `app_router.dart` to Column-based MainShell
2. Revert `mini_playbar.dart` to non-floating style
3. Revert `home_screen.dart` to SliverAppBar style
4. New glass/ directory can be deleted

## Open Questions

### Resolved
1. ~~Should glass colors be configurable?~~ → No, derive from backgroundColor
2. ~~Tab font size algorithm?~~ → Binary search with TextPainter measurement
3. ~~Safe area handling?~~ → Always MediaQuery, never hardcode

### Still Open
1. **Progress bar in mini player** - Prototype doesn't show one, current implementation has it. Remove or relocate?
   - Recommendation: Remove from mini player, keep only in full player
2. **Artist/Recommend pages** - These are currently separate routes. Should they become embedded tabs or remain as pages accessible via navigation?
   - Recommendation: Start as embedded tabs matching prototype, can add navigation shortcuts later
