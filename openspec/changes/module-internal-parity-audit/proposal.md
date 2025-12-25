# Module Internal Parity Audit

## Summary

Audit each already-aligned module layer to verify internal consistency with source project structure. This includes sub-module boundaries, file boundaries, implementation elegance, and error detection.

## Background

The previous change `align-parity-report-decisions` established correct module **layer boundaries** (core/shared/features separation). This change focuses on **internal consistency** within each layer - verifying that sub-modules and files properly mirror the source project's organizational patterns.

## Goals

1. **Sub-module boundary parity**: Verify internal structure (data/domain/presentation) aligns with source project patterns **while prioritizing Flutter/Dart best practices and elegant implementation**
2. **File boundary parity**: Verify file-to-file correspondence matches source project organization **while maintaining clean architecture and code quality standards**
3. **Implementation elegance**: Identify code that could be simplified or structured better
4. **Error detection**: Find bugs, type errors, missing implementations, dead code

## Core Principle

> **规范与优雅优先，一致性其次**
>
> Source project structure serves as a **reference**, not a rigid template. When Flutter/Dart conventions or Clean Architecture principles suggest a different approach, the target project should follow best practices rather than blindly mirroring the source.
>
> Parity is pursued **within the bounds of** proper architecture and elegant implementation, not at their expense.

## Non-Goals

- Re-analyzing or changing the module layer architecture (already done)
- Adding new features
- Refactoring working code without clear benefit

## Audit Scope

### Feature Modules (13 modules)
Each feature follows Clean Architecture with data/domain/presentation layers:

| Module | Source Reference | Priority |
|--------|------------------|----------|
| auth | `layout/navbar/login/*`, `service/passport-*` | High |
| player | `store/play-list.ts`, `layout/playbar/*` | High |
| favorites | `layout/side/collection/*`, `pages/video-collection/*` | High |
| search | `pages/search/*`, `service/web-interface-wbi-search.ts` | High |
| home | `pages/music-rank/*` | Medium |
| artist_rank | `pages/artist-rank/*` | Medium |
| music_recommend | `pages/music-recommend/*` | Medium |
| history | `pages/history/*` | Medium |
| later | `pages/later/*` | Medium |
| follow | `pages/follow-list/*` | Medium |
| user_profile | `pages/user-profile/*` | Medium |
| settings | `pages/settings/*` | Medium |
| video/audio | `service/web-interface-view.ts`, `service/audio-music-info.ts` | Low |

### Shared Layer
| Component Group | Source Reference |
|-----------------|------------------|
| widgets/playbar/* | `layout/playbar/*` |
| widgets/video_card.dart | `components/mv-card/*` |
| theme/* | `common/styles/*` |

### Core Layer
| Component Group | Source Reference |
|-----------------|------------------|
| network/* | `service/request/*` |
| utils/* | `common/utils/*` |
| constants/* | `common/constants/*` |

## Audit Checklist Per Module

For each module, verify **with the core principle in mind** (规范与优雅优先，一致性其次):

### Structure Check
- [ ] data/datasources properly wrap API calls (reference source service files, but follow Dart conventions)
- [ ] data/models correctly map API responses (may differ from source TypeScript types for Dart idioms)
- [ ] domain/entities have proper abstractions (Clean Architecture principle, not source-dependent)
- [ ] domain/repositories define correct interfaces
- [ ] presentation/screens align with source pages **where it makes sense for mobile UX**
- [ ] presentation/widgets align with source components **or use better Flutter patterns**
- [ ] presentation/providers follow Riverpod best practices (source uses Zustand, patterns will differ)

### File Check
- [ ] Each file has clear single responsibility
- [ ] File naming follows Flutter conventions (snake_case) over source patterns (kebab-case)
- [ ] No orphaned/dead files
- [ ] Imports follow layer boundaries
- [ ] **Document justified deviations from source structure**

### Code Quality Check
- [ ] No unnecessary complexity
- [ ] Consistent error handling
- [ ] Proper null safety usage
- [ ] Clean Riverpod provider patterns
- [ ] **Prefer elegant Flutter idioms over literal source translation**

### Bug Check
- [ ] Type mismatches
- [ ] Missing error states
- [ ] Race conditions
- [ ] Unhandled edge cases

## References

- `FILE_MAPPING.md` - Source to target file mapping
- `openspec/changes/align-parity-report-decisions/tasks.md` - Completed layer alignment work
- Source project: `biu/` (Electron/React)
- Target project: `biu_flutter/` (Flutter)
