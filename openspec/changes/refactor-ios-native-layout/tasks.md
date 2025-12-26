# Tasks: iOS-Native Layout Refactor

> **Implementation Context**: This Flutter project targets iOS as the primary platform. All implementations must follow iOS Human Interface Guidelines and adapt to various iPhone screen sizes using MediaQuery for safe areas.

## 1. Foundation Layer

### 1.1 Theme Constants
- [x] 1.1.1 Add iOS layout constants to `shared/theme/app_theme.dart`:
  ```dart
  // iOS-style fixed dimensions (device-independent)
  static const double miniPlayerHeight = 48;
  static const double miniPlayerRadius = 14;
  static const double miniPlayerMargin = 8;
  static const double bottomNavHeight = 49;  // iOS standard
  static const double tabFontSizeMin = 16;
  static const double tabFontSizeMax = 28;

  // Glass effect parameters
  static const double glassBlur = 20;
  static const double glassBlurStrong = 30;
  ```
- [x] 1.1.2 Update existing constants if needed (keep backward compatibility)

### 1.2 Glass Styles Utility
- [x] 1.2.1 Create `shared/widgets/glass/glass_styles.dart`:
  - `glassBackground(Color backgroundColor)` - Returns 88% opacity
  - `glassBackgroundElevated(Color backgroundColor)` - Returns 85% opacity + lightened
- [x] 1.2.2 Document that colors derive from user's `backgroundColor` setting
- [x] 1.2.3 Add helper method for ImageFilter blur creation

### 1.3 FrostedGlass Base Component
- [x] 1.3.1 Create `shared/widgets/glass/frosted_glass.dart`:
  - Must use `ClipRect` + `BackdropFilter` pattern
  - Accept `isStrong` parameter (20px vs 30px blur)
  - Accept `isElevated` parameter (standard vs elevated color)
  - Must read `backgroundColor` from `settingsNotifierProvider`
- [x] 1.3.2 Handle edge case when widget is not visible (skip blur for performance)
- [x] 1.3.3 Export from `shared/widgets/glass/glass.dart` barrel file

## 2. Bottom Section Components

### 2.1 GlassBottomNav Component
- [x] 2.1.1 Create `shared/widgets/glass/glass_bottom_nav.dart`:
  - 5 navigation items: 首页, 搜索, 收藏, 历史, 我的
  - Icons: 28x28 pixels
  - Labels: 10px font size
  - Active color from `primaryColorProvider`
  - Inactive color: white with 35% opacity
- [x] 2.1.2 Handle safe area bottom padding via `MediaQuery.of(context).padding.bottom`
- [x] 2.1.3 Implement selection state and onTap callbacks
- [x] 2.1.4 Ensure touch targets meet minimum 44pt iOS guideline

### 2.2 MiniPlaybar Refactor
- [x] 2.2.1 Modify `shared/widgets/playbar/mini_playbar.dart`:
  - Change height from 64px to 48px (`AppTheme.miniPlayerHeight`)
  - Add `ClipRRect` with 14px border radius
  - Add `BackdropFilter` with 30px blur (strong)
  - Use `GlassStyles.glassBackgroundElevated()` for background
- [x] 2.2.2 Update cover image size from 44px to 36px
- [x] 2.2.3 Remove top progress bar (or relocate based on design decision)
- [x] 2.2.4 Adjust control button layout (prev/play/next in row)
- [x] 2.2.5 Use `primaryColorProvider` for accent colors

## 3. MainShell Layout Refactor

### 3.1 Stack-Based Layout
- [x] 3.1.1 Modify `MainShell` in `core/router/app_router.dart`:
  - Change from `Column` to `Stack` layout
  - Calculate content bottom padding dynamically:
    ```dart
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final contentPadding = AppTheme.bottomNavHeight + bottomPadding +
        AppTheme.miniPlayerHeight + AppTheme.miniPlayerMargin * 2;
    ```
- [x] 3.1.2 Add bottom glass backdrop as `Positioned` widget:
  - Position: `bottom: 0, left: 0, right: 0`
  - Height: `AppTheme.bottomNavHeight + safeAreaBottom`
- [x] 3.1.3 Position MiniPlaybar as floating widget:
  - Position: `bottom: navHeight + safeBottom + margin, left: margin, right: margin`
- [x] 3.1.4 Position GlassBottomNav at bottom
- [x] 3.1.5 Ensure child content receives proper bottom padding

### 3.2 Content Padding Management
- [x] 3.2.1 Create mechanism for child screens to know required bottom inset
- [x] 3.2.2 Consider using `MediaQuery.removePadding` or custom InheritedWidget
- [x] 3.2.3 Verify CustomScrollView/ListView in child screens scroll correctly under floating elements

## 4. Home Screen Tab Refactor

### 4.1 AdaptiveTabHeader Component
- [x] 4.1.1 Create tab header widget (can be in home_screen.dart or separate file):
  - Accept list of tab labels
  - Accept current index and onTap callback
  - Use `LayoutBuilder` to get available width
- [x] 4.1.2 Implement font size calculation algorithm:
  - Binary search between 16px and 28px
  - Use `TextPainter` to measure text width
  - Account for 10px minimum gap between tabs
- [x] 4.1.3 Style tabs:
  - Active: white, FontWeight.w600
  - Inactive: white with 35% opacity, FontWeight.w600
  - Animate color transitions

### 4.2 PageView Content Structure
- [x] 4.2.1 Convert `HomeScreen` to `ConsumerStatefulWidget`
- [x] 4.2.2 Add `PageController` for tab content
- [x] 4.2.3 Implement three tab pages:
  - Tab 0: Hot Songs (热歌精选) - Current `HomeScreen` content
  - Tab 1: Artists (音乐大咖) - Content from `ArtistRankScreen`
  - Tab 2: Recommendations (音乐推荐) - Content from `MusicRecommendScreen`
- [x] 4.2.4 Sync tab header selection with PageView page changes
- [x] 4.2.5 Support swipe gestures to switch tabs

### 4.3 Top Glass Backdrop
- [x] 4.3.1 Add top `FrostedGlass` backdrop:
  - Position: `top: 0, left: 0, right: 0`
  - Height: `safeAreaTop + headerHeight` (approximately 66px header content)
- [x] 4.3.2 Position tab header above glass backdrop (higher z-index)
- [x] 4.3.3 Calculate content top padding to account for header

### 4.4 Content Area Padding
- [x] 4.4.1 Each tab page content needs:
  - Top padding: `safeAreaTop + headerHeight + spacing` (≈86px on standard iPhone)
  - Bottom padding: Handled by MainShell, but verify scrolling works
- [x] 4.4.2 Ensure RefreshIndicator works with new padding structure

## 5. Supporting Updates

### 5.1 PlaybarScaffold Update
- [x] 5.1.1 Review `PlaybarScaffold` in `app_router.dart`
- [x] 5.1.2 Update to use floating MiniPlaybar style (if applicable to non-shell routes)
- [x] 5.1.3 Or consider removing if MainShell now handles all playbar display

### 5.2 Route Cleanup
- [x] 5.2.1 Evaluate if `AppRoutes.artistRank` and `AppRoutes.musicRecommend` should remain as separate routes
  - Decision: Keep routes for deep linking, but primary access is via Home tabs
- [x] 5.2.2 If embedded in home tabs, may need to remove or redirect these routes
  - Decision: Routes remain but content is now primarily in Home tabs
- [x] 5.2.3 Update any navigation actions that reference these routes
  - Done: HomeScreen no longer navigates to these routes (uses internal tabs)

### 5.3 Export Updates
- [x] 5.3.1 Update `shared/widgets/playbar/playbar.dart` exports if needed
- [x] 5.3.2 Create `shared/widgets/glass/glass.dart` barrel file with all glass exports
- [x] 5.3.3 Update `shared/widgets/widgets.dart` if it exists

## 6. Testing & Verification

### 6.1 Visual Verification
- [ ] 6.1.1 Test on iPhone SE simulator (smallest screen, no notch)
- [ ] 6.1.2 Test on iPhone 14 simulator (standard notch)
- [ ] 6.1.3 Test on iPhone 14 Pro simulator (Dynamic Island)
- [ ] 6.1.4 Verify safe areas are correctly applied on all devices

### 6.2 Functional Testing
- [ ] 6.2.1 Verify all navigation still works (bottom nav, GoRouter)
- [ ] 6.2.2 Test mini player tap → full player
- [ ] 6.2.3 Test playback controls in mini player
- [ ] 6.2.4 Verify tab switching (tap and swipe)
- [ ] 6.2.5 Test pull-to-refresh in all tabs

### 6.3 Performance Testing
- [ ] 6.3.1 Profile frame rate during scrolling with glass effects
- [ ] 6.3.2 Verify no memory leaks from BackdropFilter
- [ ] 6.3.3 Test on lowest-spec target device (iPhone SE if available)

### 6.4 Theme Testing
- [ ] 6.4.1 Change primary color in settings → verify accent updates
- [ ] 6.4.2 Change background color → verify glass colors update
- [ ] 6.4.3 Verify all themed elements respect user settings

## 7. Documentation & Cleanup

### 7.1 Code Documentation
- [x] 7.1.1 Add dartdoc comments to all new public classes/methods
- [x] 7.1.2 Document the glass color computation logic
- [x] 7.1.3 Add comments explaining safe area handling

### 7.2 Cleanup
- [ ] 7.2.1 Remove any deprecated code paths
- [ ] 7.2.2 Remove unused imports
- [ ] 7.2.3 Run `flutter analyze` and fix any issues
- [ ] 7.2.4 Run `dart format` on all modified files

### 7.3 Git Commit
- [ ] 7.3.1 Create commit with message: `refactor(ui): implement iOS-native layout with frosted glass effects`
- [ ] 7.3.2 Push to remote repository
