# ui-components Specification Delta

## MODIFIED Requirements

### Requirement: App Layout
The application SHALL provide a consistent layout structure using Stack-based architecture for iOS-native experience.

#### Scenario: Main layout
- **GIVEN** user is on any screen within the main shell
- **WHEN** screen is displayed
- **THEN** layout SHALL use Stack with layers: content, glass backdrops, floating mini player, and bottom navigation

#### Scenario: Floating elements
- **GIVEN** main shell is displayed
- **WHEN** mini player and navigation are rendered
- **THEN** mini player SHALL float above bottom navigation with proper spacing
- **AND** bottom area SHALL have frosted glass backdrop

#### Scenario: Safe area handling
- **GIVEN** app runs on any iPhone model
- **WHEN** layout is calculated
- **THEN** safe areas SHALL be obtained via MediaQuery.of(context).padding
- **AND** no device-specific values SHALL be hardcoded

#### Scenario: Content padding
- **GIVEN** main shell with floating elements
- **WHEN** child content is displayed
- **THEN** content SHALL receive bottom padding to prevent occlusion by floating elements
- **AND** padding SHALL be dynamically calculated based on actual element heights and safe areas

### Requirement: Navigation Bar
The application SHALL provide an iOS-style bottom navigation bar with frosted glass effect.

#### Scenario: iOS glass style
- **GIVEN** app runs on iOS
- **WHEN** navigation is shown
- **THEN** navigation SHALL have transparent background with frosted glass backdrop layer behind it
- **AND** backdrop SHALL use blur effect

#### Scenario: Active indicator
- **GIVEN** user is on a tab
- **WHEN** tab is displayed
- **THEN** active tab icon and label SHALL use primary color from settings
- **AND** inactive tabs SHALL use white with 35% opacity

#### Scenario: Navigation dimensions
- **GIVEN** bottom navigation is displayed
- **WHEN** layout is calculated
- **THEN** navigation height SHALL be 49 points (iOS standard)
- **AND** icons SHALL be 28x28 points
- **AND** labels SHALL be 10 point font size

#### Scenario: Safe area bottom
- **GIVEN** iPhone with home indicator (Face ID models)
- **WHEN** navigation is displayed
- **THEN** safe area bottom padding SHALL be added below navigation items

### Requirement: Playbar Widget
The application SHALL display a floating mini playbar with frosted glass effect when audio is loaded.

#### Scenario: Floating position
- **GIVEN** audio is loaded
- **WHEN** mini playbar is displayed
- **THEN** playbar SHALL be positioned above bottom navigation with 8pt margin
- **AND** playbar SHALL have 8pt horizontal margins from screen edges

#### Scenario: Glass style
- **GIVEN** mini playbar is displayed
- **WHEN** rendered
- **THEN** playbar SHALL have frosted glass background with strong blur (30pt sigma)
- **AND** playbar SHALL have 14pt border radius
- **AND** glass color SHALL be derived from user's background color setting

#### Scenario: Collapsed state
- **GIVEN** audio is loaded
- **WHEN** mini playbar is in default state
- **THEN** mini playbar SHALL show: cover (36pt), title, and control buttons (prev/play/next)
- **AND** height SHALL be 48 points

#### Scenario: Expanded state
- **GIVEN** mini playbar is shown
- **WHEN** user taps on playbar
- **THEN** full player screen SHALL appear with all controls

#### Scenario: Theme integration
- **GIVEN** user has customized primary color in settings
- **WHEN** playbar is displayed
- **THEN** accent elements (play button, progress) SHALL use the configured primary color

## ADDED Requirements

### Requirement: Frosted Glass Component
The application SHALL provide a reusable frosted glass (backdrop blur) component.

#### Scenario: Standard blur
- **GIVEN** FrostedGlass widget is used
- **WHEN** isStrong is false (default)
- **THEN** blur sigma SHALL be 20 points

#### Scenario: Strong blur
- **GIVEN** FrostedGlass widget is used
- **WHEN** isStrong is true
- **THEN** blur sigma SHALL be 30 points

#### Scenario: Color derivation
- **GIVEN** FrostedGlass is rendered
- **WHEN** background color is determined
- **THEN** color SHALL be derived from user's backgroundColor setting with 88% opacity
- **AND** elevated variant SHALL use 85% opacity with slight lightness increase

#### Scenario: Performance optimization
- **GIVEN** FrostedGlass uses BackdropFilter
- **WHEN** widget is rendered
- **THEN** blur area SHALL be constrained with ClipRect to minimize GPU load

### Requirement: Home Tab Navigation
The application SHALL provide a tab-based home screen with swipeable content.

#### Scenario: Tab structure
- **GIVEN** user is on home screen
- **WHEN** home is displayed
- **THEN** three tabs SHALL be shown: "热歌精选" (Hot Songs), "音乐大咖" (Artists), "音乐推荐" (Recommendations)

#### Scenario: Tab header styling
- **GIVEN** tab header is displayed
- **WHEN** tabs are rendered
- **THEN** active tab SHALL be white with 600 font weight
- **AND** inactive tabs SHALL be white with 35% opacity and 600 font weight

#### Scenario: Adaptive font sizing
- **GIVEN** tab header is displayed on any iPhone width
- **WHEN** font size is calculated
- **THEN** font size SHALL be the maximum between 16pt and 28pt that allows all tabs to fit
- **AND** minimum 10pt gap SHALL be maintained between tabs

#### Scenario: Swipe navigation
- **GIVEN** user is viewing tab content
- **WHEN** user swipes left or right
- **THEN** content SHALL transition to adjacent tab
- **AND** tab header selection SHALL update accordingly

#### Scenario: Tap navigation
- **GIVEN** tab header is displayed
- **WHEN** user taps a tab label
- **THEN** content SHALL animate to that tab
- **AND** tab selection SHALL update

#### Scenario: Top glass backdrop
- **GIVEN** home screen is displayed
- **WHEN** user scrolls content
- **THEN** tab header area SHALL have frosted glass backdrop
- **AND** content SHALL scroll behind the glass effect

### Requirement: Glass Style Utilities
The application SHALL provide utility functions for computing glass effect colors.

#### Scenario: Standard glass color
- **GIVEN** a background color from settings
- **WHEN** glass background is computed
- **THEN** result SHALL be the background color with 88% opacity

#### Scenario: Elevated glass color
- **GIVEN** a background color from settings
- **WHEN** elevated glass background is computed
- **THEN** result SHALL be the background color lightened by ~8% HSL with 85% opacity

#### Scenario: Theme responsiveness
- **GIVEN** user changes background color in settings
- **WHEN** glass components are displayed
- **THEN** glass colors SHALL immediately reflect the new background color
