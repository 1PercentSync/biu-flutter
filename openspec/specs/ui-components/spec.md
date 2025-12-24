# ui-components Specification

## Purpose
TBD - created by archiving change migrate-electron-to-flutter. Update Purpose after archive.
## Requirements
### Requirement: App Layout
The application SHALL provide a consistent layout structure.

#### Scenario: Main layout
- **GIVEN** user is on any screen
- **WHEN** screen is displayed
- **THEN** layout SHALL include: navigation area, content area, and playbar (when track loaded)

#### Scenario: Navigation
- **GIVEN** main layout
- **WHEN** navigation is displayed
- **THEN** tabs/destinations SHALL include: Home, Search, Favorites, Profile

### Requirement: Navigation Bar
The application SHALL provide a top or bottom navigation bar.

#### Scenario: iOS style
- **GIVEN** app runs on iOS
- **WHEN** navigation is shown
- **THEN** bottom tab bar with icons SHALL be displayed

#### Scenario: Active indicator
- **GIVEN** user is on a tab
- **WHEN** tab is displayed
- **THEN** active tab SHALL be visually highlighted

### Requirement: Playbar Widget
The application SHALL display a persistent playbar when audio is loaded.

#### Scenario: Collapsed state
- **GIVEN** audio is loaded
- **WHEN** playbar is in default state
- **THEN** mini playbar SHALL show: cover, title, play/pause button

#### Scenario: Expanded state
- **GIVEN** mini playbar is shown
- **WHEN** user taps on playbar
- **THEN** full player screen SHALL appear with all controls

#### Scenario: Gesture dismiss
- **GIVEN** full player is open
- **WHEN** user swipes down
- **THEN** player SHALL collapse back to mini playbar

### Requirement: Video/Track List Item
The application SHALL provide a reusable list item widget for videos/tracks.

#### Scenario: Display info
- **GIVEN** a video item
- **WHEN** item is rendered
- **THEN** cover thumbnail, title, author, duration SHALL be shown

#### Scenario: Action menu
- **GIVEN** item is displayed
- **WHEN** long press or menu button pressed
- **THEN** context menu SHALL show: Play, Play Next, Add to Favorites, etc.

#### Scenario: Now playing indicator
- **GIVEN** item is currently playing
- **WHEN** item is in list
- **THEN** visual indicator (highlight/animation) SHALL show it's playing

### Requirement: Virtual List
The application SHALL efficiently render long lists using virtualization.

#### Scenario: Large list
- **GIVEN** list has hundreds of items
- **WHEN** list is scrolled
- **THEN** only visible items + buffer SHALL be rendered

#### Scenario: Scroll position
- **GIVEN** user has scrolled
- **WHEN** navigating away and back
- **THEN** scroll position SHALL be preserved

### Requirement: Image Loading
The application SHALL handle image loading with placeholders and caching.

#### Scenario: Loading state
- **GIVEN** image is being fetched
- **WHEN** image is not ready
- **THEN** placeholder or skeleton SHALL be shown

#### Scenario: Caching
- **GIVEN** image was loaded before
- **WHEN** same image is needed again
- **THEN** cached version SHALL be used

#### Scenario: Error fallback
- **GIVEN** image fails to load
- **WHEN** error occurs
- **THEN** fallback placeholder SHALL be shown

### Requirement: Search Interface
The application SHALL provide search functionality.

#### Scenario: Search input
- **GIVEN** search screen
- **WHEN** user types query
- **THEN** suggestions SHALL appear based on input

#### Scenario: Search results
- **GIVEN** user submits search
- **WHEN** results return
- **THEN** results SHALL be displayed with type tabs (All, Video, Audio, User)

#### Scenario: Search history
- **GIVEN** user has searched before
- **WHEN** search is opened
- **THEN** recent searches SHALL be shown

### Requirement: Pull to Refresh
The application SHALL support pull-to-refresh on list screens.

#### Scenario: Refresh
- **GIVEN** user is at top of list
- **WHEN** user pulls down
- **THEN** content SHALL refresh

### Requirement: Loading States
The application SHALL display appropriate loading indicators.

#### Scenario: Full page loading
- **GIVEN** page content is loading
- **WHEN** data is being fetched
- **THEN** centered loading indicator SHALL be shown

#### Scenario: Inline loading
- **GIVEN** more items are loading (pagination)
- **WHEN** user scrolls to bottom
- **THEN** loading indicator SHALL appear at bottom of list

### Requirement: Empty States
The application SHALL show meaningful empty states.

#### Scenario: Empty list
- **GIVEN** list has no items
- **WHEN** empty state is displayed
- **THEN** illustration and message SHALL explain the empty state

#### Scenario: No search results
- **GIVEN** search returns no results
- **WHEN** empty state is shown
- **THEN** message SHALL suggest different search terms

### Requirement: Error States
The application SHALL handle and display errors gracefully.

#### Scenario: Network error
- **GIVEN** network request fails
- **WHEN** error is displayed
- **THEN** retry button SHALL be available

#### Scenario: API error
- **GIVEN** API returns error
- **WHEN** error is shown
- **THEN** user-friendly message SHALL explain the issue

### Requirement: Theme Support
The application SHALL support dark theme (matching source app).

#### Scenario: Dark theme colors
- **GIVEN** theme is configured
- **WHEN** app renders
- **THEN** dark background (#18181b), content background (#1f1f1f), primary color (#17c964) SHALL be used

#### Scenario: Custom colors (future)
- **GIVEN** settings allow color customization
- **WHEN** user changes colors
- **THEN** app theme SHALL update accordingly

