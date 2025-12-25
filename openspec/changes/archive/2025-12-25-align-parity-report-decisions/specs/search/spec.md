# Search Capability - Delta Specification

## REMOVED Requirements

### Requirement: Hot Search Keywords

**Reason:** Source project (biu/Electron) does not have hot search/trending feature. This was incorrectly added during Flutter implementation.

**Migration:** Remove all hot search related code:
- Remove `hotSearchKeywordsProvider` from search providers
- Remove `getHotSearchKeywords()` from search datasource
- Remove hot search UI section from search screen
- Keep search history functionality (exists in source)

#### Scenario: Search suggestions without hot searches (removed behavior)
- **WHEN** search field is focused with empty query
- ~~**THEN** hot search keywords are displayed~~
- **THEN** only search history is displayed

---

## MODIFIED Requirements

### Requirement: User Search Result Navigation

The search screen SHALL navigate to user profile when a user search result is tapped.

#### Scenario: Navigate to user profile from search
- **WHEN** user searches for users
- **AND** user taps on a user search result
- **THEN** user profile screen is displayed for that user
- **AND** navigation uses `/user/:mid` route

#### Scenario: User search result tap behavior
- **WHEN** user taps on user search result card
- **THEN** no snackbar or toast is shown
- **AND** direct navigation occurs

---

### Requirement: Search Suggestions Content

The search suggestions area SHALL display only search history when search field is focused with empty query.

#### Scenario: Empty query suggestions
- **WHEN** search field is focused
- **AND** query is empty
- **THEN** search history section is displayed
- **AND** no trending/hot searches section is displayed

#### Scenario: Search history interaction
- **WHEN** search history is displayed
- **THEN** user can tap history item to search
- **AND** user can delete individual history items
- **AND** user can clear all history
