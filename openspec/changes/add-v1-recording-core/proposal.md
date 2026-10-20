# Proposal: daily recording and persistence

## Why

M1 needs daily medication, meal and toilet records that survive restart and can be reviewed by day.
The merged Today screen currently displays only synthetic samples. This retained change is narrowed
from the original v1 bundle, preserving traceability to the merged skeleton and PR #5.

## What Changes

- Implement the three peer recording flows, shared timestamps, completeness and edit history.
- Add backfill, day-based viewing, editing, deletion and local persistence.
- Verify one real-device installation and large-text usability as part of M1 acceptance.
- Move biologics, trends, daily confirmation and visit summary into separately verifiable changes.
- Keep unspecified fields, meal photos and interaction details open until their slice is discussed.

## Capabilities

### New Capabilities

- `event-recording`: daily records, their lifecycle, local storage and day-based retrieval.

### Modified Capabilities

None; no main capability specs have been published yet.

## Impact

Features, domain types and SwiftData mapping will replace the screen's sample-only state. This PR
changes planning, not app behavior. The iteration method and milestone scope are in
[the delivery plan](../../../docs/process/delivery-plan.md).
The original encrypted-backup-before-real-data prerequisite remains unresolved there; this split
neither waives it nor claims that storage or backup exists.
