# Core Infrastructure - Delta Specification

## ADDED Requirements

### Requirement: Source Reference Documentation

All public APIs in the Flutter project SHALL include documentation comments that reference their source location in the Electron project.

#### Scenario: Function documentation with source reference
- **WHEN** a public function is defined
- **THEN** it includes a doc comment with description
- **AND** it includes a `Source:` line referencing the Electron file and function name

#### Scenario: Class documentation with source reference
- **WHEN** a public class is defined
- **THEN** it includes a doc comment with description
- **AND** it includes a `Source:` line referencing the Electron file and class/component name

#### Scenario: Flutter-only code documentation
- **WHEN** code has no direct Electron equivalent
- **THEN** it includes a doc comment with description
- **AND** it includes `Source: Flutter-only` annotation
