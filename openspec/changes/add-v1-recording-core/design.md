# Design: daily records and persistence

## Context

See proposal.md for the revised scope. TodayView and RecordedEvent are a merged visual skeleton, not
a domain model or store. Their string times, icons, localization and test launch arguments must not
become the persistence contract. Other capabilities now own their own plans.

## Goals / Non-Goals

Keep data semantics independent of SwiftUI, formatting and SwiftData so records, history and trends
share one meaning. This change does not implement the later daily-confirmation or export screens.

## Decisions

- Keep a shared event envelope and typed daily payloads. Stable IDs, happened-at, recorded-at and
  history belong to domain values; display strings belong in the feature. Alternative: reuse the
  sample model, which loses timestamps and couples data to presentation.
- Preserve the existing four completeness states and explicit-zero distinction. A saved event does
  not prove the whole day is complete. Alternative: infer a day's completeness from event presence,
  which mistakes partial histories for totals.
- Retain SwiftData as the planned local store, mapping to domain values. Confirm its migration/error
  policy in the persistence slice and record the storage ADR before production integration. In-memory
  and persistent adapters exercise the same recording behavior; avoid extra abstraction without use.
- Exercise one vertical save/relaunch/history path early. Screens may first use synthetic in-memory
  data, but each finished recording slice must be verified against persistence.
- Keep day-window and counting rules in testable domain logic. Rendering never determines counts.

## Risks / Trade-offs

- [Date and deletion semantics are unresolved] -> Settle them before the affected model/query slice;
  add boundary and correction scenarios, then code against those decisions.
- [Migration can lose dogfood history] -> Version the first persistent schema and rehearse migration
  before changing it; destructive reset is not a recovery plan once real records exist.
- [Real-data backup prerequisite remains open] -> Use the gate in the delivery plan before device use
  with real records; synthetic device rehearsals can proceed.

## Slice decisions

The maintainer requested incremental design. Required form fields, photo support, delete/undo behavior,
time-zone policy and screen structure are deliberately not approved by this outline. Resolve each in
its owning Issue, update this change and its tests, then implement that slice.
