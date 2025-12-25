# User Profile Capability - Delta Specification

## ADDED Requirements

### Requirement: Dynamic Feed Tab

The user profile screen SHALL display a Dynamic tab showing the user's activity feed including videos, images, and text posts.

#### Scenario: Dynamic tab displays in tab bar
- **WHEN** user opens any user profile
- **THEN** Dynamic tab is displayed as the first tab
- **AND** tab label is "Dynamic" (or localized equivalent)

#### Scenario: Dynamic feed loads on tab selection
- **WHEN** user selects Dynamic tab
- **THEN** user's dynamic feed is fetched from API
- **AND** feed items are displayed in chronological order (newest first)

#### Scenario: Dynamic feed pagination
- **WHEN** user scrolls to bottom of dynamic feed
- **AND** more items are available
- **THEN** next page is loaded using offset cursor
- **AND** new items are appended to list

#### Scenario: Dynamic item types
- **WHEN** dynamic feed is displayed
- **THEN** video dynamics show video thumbnail, title, and stats
- **AND** image dynamics show image grid with description
- **AND** text dynamics show text content only
- **AND** repost dynamics show original content with repost context

#### Scenario: Empty dynamic feed
- **WHEN** user has no dynamics
- **THEN** empty state is displayed with appropriate message

---

### Requirement: Video Series Tab

The user profile screen SHALL display a Video Series (Union) tab showing the user's video collections/seasons.

#### Scenario: Video Series tab displays in tab bar
- **WHEN** user opens any user profile
- **THEN** Video Series tab is displayed as the fourth tab
- **AND** tab label is "Series" (or localized equivalent)

#### Scenario: Video series list loads on tab selection
- **WHEN** user selects Video Series tab
- **THEN** user's seasons and series list is fetched from API
- **AND** items are displayed in a grid layout

#### Scenario: Video series item display
- **WHEN** video series list is displayed
- **THEN** each item shows cover image, title, and video count
- **AND** items are tappable

#### Scenario: Video series navigation
- **WHEN** user taps a video series item
- **THEN** series detail screen is displayed
- **AND** series videos are listed

#### Scenario: Empty video series
- **WHEN** user has no video series
- **THEN** empty state is displayed with appropriate message

---

## MODIFIED Requirements

### Requirement: User Profile Tab Configuration

The user profile screen SHALL display tabs in a specific order matching the source project configuration.

#### Scenario: Complete tab order
- **WHEN** user profile screen is displayed
- **THEN** tabs are shown in order: Dynamic, Videos, Favorites, Series
- **AND** Favorites tab visibility depends on privacy settings

#### Scenario: Tab visibility based on privacy
- **WHEN** viewing own profile
- **THEN** all tabs are visible
- **WHEN** viewing other user's profile
- **AND** user has hidden favorites
- **THEN** Favorites tab is hidden

#### Scenario: Tab controller configuration
- **WHEN** tab count changes due to visibility rules
- **THEN** tab controller is reconfigured
- **AND** current selection is preserved if possible
