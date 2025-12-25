## ADDED Requirements

### Requirement: Type Safety Compliance

All model classes SHALL use strongly-typed fields that match API response types and route parameter expectations.

#### Scenario: Model type matches route expectations
- **WHEN** a model field is used as a route parameter
- **THEN** the model field type MUST match the route parameter type
- **AND** no runtime type conversion SHALL be needed at call site

#### Scenario: Model type matches API response
- **WHEN** parsing API JSON response into a model
- **THEN** the fromJson method SHALL use the correct Dart type for each field
- **AND** type mismatches SHALL be caught at compile time

### Requirement: API Parameter Completeness

All API calls SHALL include required parameters as specified by the source project implementation.

#### Scenario: WBI signature requirement
- **WHEN** an API endpoint requires WBI signature (as per source project)
- **THEN** the Dio request SHALL include `Options(extra: {'useWbi': true})`

#### Scenario: Platform parameter requirement
- **WHEN** an API endpoint requires platform identification
- **THEN** the request SHALL include `platform: 'web'` parameter

### Requirement: Resource Lifecycle Management

Long-lived resources (services, streams, subscriptions) SHALL be properly released in all code paths.

#### Scenario: Initialization failure cleanup
- **WHEN** service initialization fails with an exception
- **THEN** any partially initialized resources SHALL be disposed
- **AND** the exception SHALL be rethrown after cleanup

#### Scenario: Normal disposal
- **WHEN** a notifier or service is disposed
- **THEN** all subscriptions SHALL be cancelled
- **AND** all owned services SHALL be disposed

### Requirement: UI State Reactivity

UI components displaying mutable state SHALL correctly react to state changes.

#### Scenario: Popup menu state updates
- **WHEN** state changes while a popup menu is open
- **THEN** the popup content SHALL reflect the new state
- **AND** user interactions SHALL update the displayed value immediately

### Requirement: Dead Code Elimination

Unused code artifacts SHALL be removed from the codebase.

#### Scenario: Unused class removal
- **WHEN** a class has no references in the codebase
- **THEN** the class SHALL be deleted
- **AND** its containing file SHALL be deleted if empty

#### Scenario: Unused method removal
- **WHEN** a method has no callers
- **THEN** the method SHALL be removed
- **AND** related documentation SHALL be updated

### Requirement: Source Project Language Alignment

User-facing strings SHALL use the same language as the source project.

#### Scenario: Chinese UI strings
- **WHEN** displaying UI text that exists in the source project
- **THEN** the text SHALL match the source project language (Chinese)
- **UNTIL** an internationalization system is implemented

### Requirement: Constants Completeness

Enumeration and constant definitions SHALL be complete as per source project.

#### Scenario: VideoFnval constants
- **WHEN** using video format flags
- **THEN** all flags defined in source project SHALL be available
- **AND** bitwise combinations SHALL work correctly

#### Scenario: VipType enumeration
- **WHEN** checking user VIP status
- **THEN** named enum values SHALL be used instead of magic numbers
- **AND** the enum SHALL include all types from source project
