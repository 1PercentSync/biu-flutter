# search Specification

## Purpose
TBD - created by archiving change align-flutter-with-electron. Update Purpose after archive.
## Requirements
### Requirement: Music Category Filter

The search system SHALL provide a "Music Only" filter toggle that restricts search results to the music category (tids: 3).

The filter MUST be enabled by default to match the source application behavior, as this is a music-focused application.

#### Scenario: Default search filters to music category
- **WHEN** user opens the search screen
- **THEN** the "Music Only" toggle is enabled by default
- **AND** search results only include videos from the music category (tids: 3)

#### Scenario: User disables music filter
- **WHEN** user toggles off the "Music Only" filter
- **THEN** subsequent searches return results from all categories
- **AND** the filter state persists during the session

#### Scenario: Music filter applied to search API
- **WHEN** user performs a search with "Music Only" enabled
- **THEN** the API call includes `tids=3` parameter
- **AND** results contain only music-related content

---

### Requirement: Search History Management

The search system SHALL maintain a persistent history of user search queries with the ability to view, use, and manage history items.

#### Scenario: Search query added to history
- **WHEN** user submits a search query
- **THEN** the query is added to search history with current timestamp
- **AND** duplicate entries are removed (most recent kept)
- **AND** history is persisted to local storage

#### Scenario: Search history displayed on focus
- **WHEN** user focuses the search input with empty query
- **THEN** recent search history is displayed below the input
- **AND** items show the search term and relative time
- **AND** each item has a delete button

#### Scenario: Search from history
- **WHEN** user taps a history item
- **THEN** the search query is populated with that term
- **AND** search is executed automatically

#### Scenario: Delete single history item
- **WHEN** user taps the delete button on a history item
- **THEN** that item is removed from history
- **AND** the UI updates immediately

#### Scenario: Clear all history
- **WHEN** user taps "Clear All" button
- **THEN** all history items are removed
- **AND** the history section is hidden

#### Scenario: History limit enforcement
- **WHEN** history exceeds 50 items
- **THEN** oldest items are automatically removed
- **AND** most recent 50 items are retained

---

### Requirement: Search Results Pagination

The search system SHALL support pagination of search results to enable browsing beyond the initial result set.

#### Scenario: Initial search returns paginated results
- **WHEN** user performs a search
- **THEN** first page of results is displayed
- **AND** pagination state (current page, total, hasMore) is tracked

#### Scenario: Load more results
- **WHEN** user scrolls to bottom of results OR taps "Load More"
- **THEN** next page of results is fetched
- **AND** new results are appended to existing list
- **AND** loading indicator is shown during fetch

#### Scenario: End of results reached
- **WHEN** all available results have been loaded
- **THEN** "No more results" indicator is shown
- **AND** further load attempts are prevented

---

### Requirement: User Search

The search system SHALL support searching for Bilibili users in addition to video search.

#### Scenario: Switch to user search
- **WHEN** user selects the "Users" tab in search
- **THEN** search results display user profiles instead of videos
- **AND** search API uses `search_type=bili_user`

#### Scenario: User search results display
- **WHEN** user search returns results
- **THEN** each result shows: avatar, username, signature, fans count, video count
- **AND** results are displayed in a grid or list format

#### Scenario: Navigate to user profile
- **WHEN** user taps a user search result
- **THEN** navigation to that user's profile screen occurs

