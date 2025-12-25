# Change: Apply Audit Fixes from Module Internal Parity Audit

## Why

The module-internal-parity-audit change has completed a comprehensive audit of all 17 modules in biu-flutter. The audit identified 38 issues across the codebase, of which 32 require implementation fixes. These range from a critical compilation error blocking app builds to medium-priority functional bugs and low-priority code quality improvements.

**Key Statistics:**
- Total Issues: 38
- Fixes Required: 32
- No Action Needed: 6 (design decisions aligned with source project)
- Critical (compilation blocking): 1
- Medium (functional bugs): 5
- Low (code quality): 26

## Project Spirit

This change adheres to the project's core principle:

> **规范与优雅优先，一致性其次**
> (Standards and elegance first, consistency second)

Implementation decisions:
1. **Standards First**: Follow Dart/Flutter best practices and Clean Architecture principles
2. **Elegance Second**: Prefer simple, readable solutions over clever but complex ones
3. **Consistency Third**: Align with source project (biu) behavior where it doesn't conflict with #1 and #2

## What Changes

### CRITICAL (Must fix immediately)
- **artist_rank**: Fix `Musician.uid` type mismatch (String → int) causing compilation error

### Medium Priority (Functional bugs)
- **later**: Add missing WBI signature for API calls
- **favorites**: Implement hidden folder filtering
- **shared/playbar**: Fix volume slider state in popup
- **player**: Add resource cleanup on initialization failure
- **core/utils**: Remove unused ColorUtils and Throttler classes

### Low Priority (Code quality)
- **auth**: Remove 3-country fallback, verify Geetest UI
- **player**: Fix URL race condition
- **favorites**: Add platform parameter, extract duplicate method
- **search**: Improve error display, remove dead code, add loading state
- **home**: Change English strings to Chinese, add refresh indicator
- **artist_rank**: Change English strings to Chinese
- **history/later**: Fix code style (empty lines in function calls)
- **user_profile**: Use route constants, add barrel export
- **settings**: Read version from package_info_plus
- **shared/playbar**: Fix dynamic type, mute button UX, update docs
- **core/network**: Fix cookie domain, improve comments, add null check
- **core/utils**: Complete VideoFnval constants, add VipType enum
- **video/audio**: Fix AudioQuality docs, return typed objects

## Impact

### Affected Modules (14 of 17)
- features/artist_rank
- features/auth
- features/favorites
- features/history
- features/home
- features/later
- features/player
- features/search
- features/settings
- features/user_profile
- shared/widgets/playbar
- core/network
- core/utils
- video/audio

### Unaffected Modules (Exemplary)
- features/music_recommend (5/5)
- features/follow (5/5)
- shared/widgets (5/5)

### Code Files (~25 files)
See tasks.md for complete file list per task.

## Risk Assessment

- **Low Risk**: Most changes are localized bug fixes or code cleanup
- **Medium Risk**: #1 (uid type change) may require updates in multiple places
- **No Breaking Changes**: All fixes maintain existing API contracts

## Success Criteria

1. `flutter analyze` reports no errors
2. `flutter build` succeeds for all platforms
3. All modified modules maintain their audit score or improve
4. Source project parity is maintained where applicable
