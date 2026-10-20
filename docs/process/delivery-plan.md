# Delivery plan

## M1: personal dogfood MVP

Scope authority: [ADR-0014](../adr/0014-m1-dogfood-and-iterative-delivery.md). Live progress is on
[the M1 board](https://github.com/IBDer/IBDer/milestone/1); each change tracks implementation tasks. Cross-capability device acceptance is tracked in
[issue #26](https://github.com/IBDer/IBDer/issues/26), and trends in
[issue #25](https://github.com/IBDer/IBDer/issues/25).

| Capability | OpenSpec change | What proves completion |
| --- | --- | --- |
| Daily medication, meal and toilet records | `add-v1-recording-core` | Each flow saves, supports backfill and can be reviewed, edited and deleted by day; timestamps and history survive restart. |
| Biologic kinds, appointments and local reminders | `add-biologic-schedule` | The kind is retained, appointments can be changed or cancelled, reminders follow them, and only explicit recording creates an actual dose. |
| Week, month, six-month and year trends | `add-objective-trends` | All ranges work with short histories and synthetic year-long fixtures; figures trace to records, distinguish missing data and update after edits. |
| Device readiness | Recording and cross-capability acceptance tasks | Development signing works on the maintainer's phone; maximum text size remains usable; three days of records survive relaunch and appear in history and trends. |

The Today screen is a merged visual skeleton (PR #5). Its sample data and placeholder actions do not
complete recording, persistence or reminders.

### Discuss when the relevant slice starts

| Slice | Choices to settle before production implementation |
| --- | --- |
| Record semantics | Local-day/time-zone policy, edit/delete behavior and completeness representation. |
| Recording forms | Required fields, quick-save behavior, meal photos and supplement representation. Photos remain undecided. |
| Biologics | How kinds are entered, single or recurring appointments, reminder lead times and actions, and notification permission handling. |
| Trends | Useful metrics, exact date-window boundaries, bucket sizes, denominators, browsing and chart interactions. |
| Device trial | Resolve the backup prerequisite below and settle installation and recovery instructions. |

Explore the current slice, show a prototype when useful, record the maintainer's decision in the
affected artifacts, then implement. A layout adjustment does not restart the whole milestone plan.

### Real-data readiness

The earlier recording proposal required encrypted backup and restore before real patient use, while
the board scheduled that work in M3. The new M1 requires personal use but did not explicitly waive that
constraint. Track its resolution in [M1 decision #27](https://github.com/IBDer/IBDer/issues/27): deliver the paired capability before the real-data
trial, or obtain an explicit maintainer decision changing the prerequisite and update its documents.
Until then, development and device rehearsals use synthetic data. Closing functional issues alone
does not clear this gate.

### Suggested sequence

1. Refine one daily recording path and prove its save/relaunch/day-history loop, then extend the shared
   model and storage to the other daily types.
2. Build biologic kinds and appointments, then connect reminders and explicit actual-dose recording.
3. Build one agreed trend metric end to end, then extend it to the agreed metrics and all four ranges.
4. Complete device acceptance across flows, including edits, deletions, missing days, large text and
   notification states. Use synthetic data until the real-data gate is resolved.

UI-first prototypes may use an in-memory store. Each production slice lands its own tests and updated
scenarios; persistence and date rules are exercised early rather than after every form is finished.

## M2: external TestFlight and follow-up capabilities

- `add-daily-confirmation`: totals, symptom selections and explicit daily completeness; revisit its
  necessity and interaction before implementation. M1 trends must work without this screen.
- `add-visit-summary`: a period summary and human-readable plus structured export.
- External installation and feedback, with distribution identity and clinical wording decisions.

These are plans, not delivered behavior. Moving them out of the recording change does not complete
them. Revise their owning change when dogfooding changes the requirements.

## M3: public release

Public-release requirements include policy, filing, clinical review, store assets and data recovery.
Backup timing is subject to the unresolved M1 gate above, not automatically postponed to release.

## Proposed versus delivered specifications

`openspec/changes/` holds proposed behavior; `openspec/specs/` describes verified, delivered behavior.
Main specs are still empty; no capability becomes complete through this planning reorganisation.
After a capability is implemented and reviewed, verify it and sync its delta. A partial implementation
PR does not justify copying every planned requirement into main specs.
