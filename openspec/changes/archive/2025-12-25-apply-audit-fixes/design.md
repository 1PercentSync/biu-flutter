# Design: Audit Fixes Implementation Guide

## Context

This document provides implementation guidance for agents executing the 32 audit fixes. Each fix should be implemented following the principles and patterns documented here.

## Goals / Non-Goals

### Goals
- Fix all 32 identified issues from the audit
- Maintain or improve code quality scores
- Preserve source project parity where appropriate
- Ensure all changes compile and pass analysis

### Non-Goals
- Refactoring beyond the scope of identified issues
- Adding new features
- Changing architecture patterns
- Optimizing performance (unless explicitly identified as an issue)

## Implementation Principles

### 1. 规范与优雅优先，一致性其次 (Standards and Elegance First, Consistency Second)

When implementing fixes:
1. **First Priority**: Follow Dart/Flutter best practices
   - Use type-safe code (avoid `dynamic` unless necessary)
   - Follow Effective Dart guidelines
   - Use proper null safety

2. **Second Priority**: Keep code elegant and simple
   - Prefer readable code over clever solutions
   - Use self-documenting variable/method names
   - Keep functions focused and small

3. **Third Priority**: Align with source project
   - Only when it doesn't violate #1 or #2
   - Document deviations with clear reasoning

### 2. Module Boundary Respect

Each module follows Clean Architecture:
```
features/[module]/
├── data/
│   ├── datasources/    # Remote/Local data sources
│   ├── models/         # Data transfer objects
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business objects
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic (if needed)
└── presentation/
    ├── providers/      # State management
    ├── screens/        # Full-page widgets
    └── widgets/        # Reusable components
```

**Rules:**
- Data layer changes stay in data layer
- Presentation layer may import from domain and data (for models)
- Cross-feature imports allowed only in presentation layer of aggregate pages

### 3. Exemplary Module Reference

When in doubt, reference these modules with perfect (5/5) audit scores:
- `features/music_recommend` - Feature module reference
- `features/follow` - Clean Architecture example
- `shared/widgets` - Layer boundary compliance
- `core/network` - Abstraction design
- `video/audio` - Pure data layer service

## Decisions

### D1: Type Consistency Strategy
For #1 (uid type mismatch):
- **Decision**: Change `Musician.uid` to `int` type
- **Rationale**: Routes expect int, API returns int, String storage was incorrect
- **Migration**: Update model, fromJson parsing, and all usages

### D2: Localization Strategy
For #20, #22 (English strings):
- **Decision**: Replace English with Chinese strings directly (no i18n framework yet)
- **Rationale**: Source project uses Chinese, no i18n infrastructure exists
- **Future**: When i18n is added, these will be extracted to translation files

### D3: Dead Code Removal
For #7, #17 (unused code):
- **Decision**: Delete unused code entirely
- **Rationale**: Dead code increases maintenance burden
- **Verification**: Search codebase to confirm no usage before deletion

### D4: API Parameter Alignment
For #2, #12 (missing API parameters):
- **Decision**: Add missing parameters to match source project
- **Rationale**: API contracts should be complete
- **Pattern**: Use `Options(extra: {'useWbi': true})` for WBI

### D5: Constants vs Enums
For #35, #36 (VideoFnval, VipType):
- **Decision**: Use abstract class with static const for VideoFnval, enum for VipType
- **Rationale**: VideoFnval uses bitwise flags (class), VipType is discrete values (enum)
- **Pattern**: Follow existing `AudioQuality` pattern

## Common Patterns

### Pattern: WBI Signature
```dart
final response = await _dio.get<Map<String, dynamic>>(
  '/api/endpoint',
  queryParameters: params,
  options: Options(extra: {'useWbi': true}),  // Add this
);
```

### Pattern: Type-Safe Models
```dart
// Instead of returning Map<String, dynamic>
AudioStreamInfo getAudioInfo() {
  return AudioStreamInfo(
    url: data['cdns']?[0] ?? '',
    quality: data['type'] ?? 0,
  );
}
```

### Pattern: Resource Cleanup
```dart
Future<void> initialize() async {
  try {
    await _service.init();
    // ... more init logic
  } catch (e) {
    await _service.dispose();  // Clean up on failure
    rethrow;
  }
}
```

### Pattern: Popup State Management
```dart
// Use Consumer inside PopupMenu for reactive updates
PopupMenuItem(
  child: Consumer(
    builder: (context, ref, _) {
      final value = ref.watch(provider.select((s) => s.value));
      return Slider(value: value, ...);
    },
  ),
)
```

## Risks / Trade-offs

### R1: Type Change Ripple Effect (#1)
- **Risk**: Changing uid from String to int may affect multiple files
- **Mitigation**: Search for all usages of `Musician.uid` before changing
- **Verification**: Run `flutter analyze` after change

### R2: API Behavior Change (#2, #12)
- **Risk**: Adding parameters might change API behavior
- **Mitigation**: Parameters match source project which works correctly
- **Verification**: Manual testing of affected features

### R3: Removing Fallback (#8)
- **Risk**: Removing country fallback may affect offline UX
- **Mitigation**: Keep default "86" which is the source project behavior
- **Verification**: Test login flow when API fails

## Validation Checklist

After each task:
1. [ ] `flutter analyze` passes with no errors
2. [ ] Changed files follow Effective Dart guidelines
3. [ ] No new warnings introduced
4. [ ] Module boundary rules respected

After all tasks:
1. [ ] `flutter build apk` succeeds
2. [ ] All affected modules still function correctly
3. [ ] No regression in existing features
