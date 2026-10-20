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
- Store the records in one versioned JSON archive written atomically, behind `EventStore`
  (ADR-0015). A failed write is reported and never cached as saved; a newer schema is refused rather
  than overwritten. The in-memory store exercises the same recording behaviour in previews and tests.
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

Agreed with the maintainer on 2026-10-20, before this slice was implemented:

- **Three tabs**: today, trends, settings. The day screen keeps its date header and three recording
  entry points fixed while the timeline scrolls.
- **Day boundary**: local midnight. 23:59 and 00:01 are different days; a past day keeps the current
  clock time when a record is backfilled.
- **Backfill**: any past date. A record entered on a later day than it happened is marked as
  backfilled, without a warning or a colour.
- **Editing**: previous values are kept in `revisions`; the original recorded-at never changes. The row
  says only that it was edited.
- **Deleting**: a soft delete with a five-second undo. The same record comes back, with its history.
- **Gestures**: swipe left to delete, swipe right to edit, tap to open the record.
- **Toilet fields**: the four outcomes first; Bristol type, blood amount and perianal sensation only
  for a stool. Blood and perianal sensation are optional, because not reporting them is not the same
  as reporting none.
- **Completeness**: M1 never asks and never displays it. A day without records is empty, not zero.
- **Photos**: not in M1.
- **Meal and medication forms**: implemented as a first cut ahead of their own design conversation;
  their tasks stay unchecked until the maintainer agrees the fields.
