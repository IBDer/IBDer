# Architecture Specification

**Status: draft, pending review.** The first version is iOS native (SwiftUI).

## Layering and Dependency Direction

Dependencies may only point downward, **never in reverse, and never jumping back across layers**:

```
App          ← composition, navigation, dependency injection
  Features   ← one directory per feature the Patient can perceive
    Domain   ← pure logic: entities, value objects, rules, use cases
      Core   ← platform-independent utilities (time, ID, serialization)
    Data     ← persistence and export implementations
  DesignSystem ← design tokens and shared components
```

- **Domain does not know about UI, and does not know about persistence.** It does not import SwiftUI and does not import SwiftData.
- Features must not import one another; anything shared sinks down into Domain or DesignSystem.
- Data depends on protocols defined by Domain, never the reverse.

## Why This Cut

- Pure Domain logic → the fastest unit tests can cover statistics definitions, RecordCompleteness rules, and date windows; this is where mistakes cost the most in this project.
- UI and persistence are replaceable → the first version stores locally, and if sync is wanted later, the rules layer does not have to be rewritten.

## Directory Conventions

```
IBDer/
  App/
  Features/
    ToiletEvent/
    DailyConfirmation/
    VisitSummary/
  Domain/
    Entities/
    Rules/
    UseCases/
  Data/
    Persistence/
    Export/
  DesignSystem/
    Tokens/
    Components/
IBDerTests/
IBDerUITests/
```

## State and Data Flow

- Unidirectional data flow: View emits an intent → UseCase mutates state → View observes state and redraws.
- Do not carry business state in a global mutable singleton; dependencies are injected from the App layer.
- Dates and times are always obtained from an injectable clock; calling the current time directly inside Domain is forbidden (this is the precondition for testability).

## Persistence

- The first version stores locally; the specific technology (SwiftData or another) is decided when that change is implemented and recorded in an ADR.
- **No write failure may ever let the UI display "Saved".**

## Module Depth

- Prefer "small interface + thick implementation". A module's public interface should be narrow enough to describe in a few sentences.
- Do not abstract prematurely for reuse; extract when a third caller appears.
