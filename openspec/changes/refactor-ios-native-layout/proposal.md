# Change: Refactor Layout to iOS-Native Style with Frosted Glass Effects

## Why

The Flutter project targets iOS as the primary platform (see `openspec/project.md`). The current implementation uses Material Design patterns (Column-based layout, Material NavigationBar) which feel foreign on iOS. A prototype (`prototype/home_tabs_prototype.html`) demonstrates the desired iOS-native experience with:

1. **Frosted glass effects** - iOS signature visual style (like Apple Music, App Store)
2. **Floating mini player** - Positioned above bottom navigation instead of inline
3. **Tab-based home screen** - Swipeable tabs instead of separate pages
4. **Proper safe area handling** - Dynamic adaptation to various iPhone notch/Dynamic Island sizes

This refactor aligns the UI with iOS Human Interface Guidelines and the approved prototype design.

## What Changes

### Layout Architecture
- **BREAKING**: `MainShell` changes from `Column` to `Stack` layout
- Mini player becomes a floating widget with backdrop blur
- Bottom navigation becomes transparent with frosted glass background
- Content area receives dynamic padding based on floating elements

### New Components
- `FrostedGlass` widget - Reusable backdrop blur container
- `GlassBottomNav` widget - iOS-style transparent navigation
- `AdaptiveTabHeader` widget - Auto-sizing tab labels

### Home Screen
- **BREAKING**: Home changes from single-page to tab-based design
- Three tabs: Hot Songs (热歌精选), Artists (音乐大咖), Recommendations (音乐推荐)
- PageView with swipe gesture and tab synchronization

### Theme System
- Add iOS-specific layout constants (not changing color defaults)
- Add frosted glass style utilities (computed from user's theme colors)
- Frosted glass colors derived from `backgroundColor` setting

### Responsive Design
- All safe area values via `MediaQuery.of(context).padding`
- Tab font size auto-scales based on available width
- No hardcoded device-specific dimensions

## Impact

### Affected Specs
- `ui-components` - Major changes to layout, navigation, playbar requirements
- `settings` - No schema changes (uses existing `primaryColor`, `backgroundColor`)

### Affected Code

**Core Files (Must Modify):**
- `core/router/app_router.dart` - MainShell layout restructure
- `shared/widgets/playbar/mini_playbar.dart` - Frosted glass style, floating position
- `features/home/presentation/screens/home_screen.dart` - Tab-based redesign
- `shared/theme/app_theme.dart` - Add iOS layout constants

**New Files:**
- `shared/widgets/glass/frosted_glass.dart` - Backdrop blur container
- `shared/widgets/glass/glass_styles.dart` - Color computation utilities
- `shared/widgets/glass/glass_bottom_nav.dart` - iOS-style navigation

**Potentially Affected:**
- `shared/widgets/playbar/playbar.dart` (exports)
- All screens using `PlaybarScaffold`
- Any widget depending on `MiniPlaybar` positioning

## Platform Context

**Target Platform**: iOS (iPhone)
**Development Platform**: Windows
**Final Build**: macOS → iOS App Store

This change specifically addresses iOS platform conventions. The prototype dimensions (390×844) represent iPhone 14, but implementation MUST adapt to all iPhone sizes:

| Device | Screen | Safe Area Top | Safe Area Bottom |
|--------|--------|---------------|------------------|
| iPhone SE 3 | 375×667 | 20px | 0px |
| iPhone 8 | 375×667 | 20px | 0px |
| iPhone X/11 Pro | 375×812 | 44px | 34px |
| iPhone 12/13/14 | 390×844 | 47px | 34px |
| iPhone 14 Pro | 393×852 | 59px | 34px |
| iPhone 14 Pro Max | 430×932 | 59px | 34px |

All safe area values MUST be obtained via `MediaQuery`, never hardcoded.

## Design Reference

Prototype file: `prototype/home_tabs_prototype.html`

Key design tokens from prototype (for reference, not hardcoding):
```css
/* Fixed UI dimensions (device-independent) */
--tab-bar-height: 49px;       /* iOS standard */
--mini-player-height: 48px;
--mini-player-radius: 14px;
--mini-player-margin: 8px;

/* Glass effect parameters */
--glass-blur: 20px;
--glass-blur-strong: 30px;
--glass-saturate: 180%;

/* Responsive font sizing */
--tab-font-size-min: 16px;
--tab-font-size-max: 28px;
```
