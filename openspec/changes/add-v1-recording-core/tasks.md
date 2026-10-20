# Tasks: daily recording and persistence

This change now owns only daily recording. PR #5 merged the skeleton and Today entry-point screen;
that evidence completes 1.1-1.4 and 4.1, not the placeholder buttons' recording behavior.
The original schedule, daily-confirmation and summary tasks moved into their own named changes.
For each unchecked slice, discuss its unresolved product details and update scenarios before coding.

## 1. Merged skeleton

- [x] 1.1 Create the iOS app target — verified by the merged simulator build.
- [x] 1.2 Add DesignSystem tokens — verified by the existing token unit tests.
- [x] 1.3 Add SwiftFormat and SwiftLint in CI — verified by the merged CI runs.
- [x] 1.4 Add unit, UI and snapshot targets — verified by their build and execution/skip reporting; snapshot runtime alignment remains an acceptance task below.

## 2. Record semantics (issue #7)

- [ ] 2.1 Agree local-day/time-zone, backfill and edit semantics; update this spec/design with examples — verify the maintainer's decision and boundary scenarios are recorded.
- [ ] 2.2 Implement the envelope and typed daily payloads — verify stable IDs, both timestamps and previous-value history with unit tests, including an urge-only event excluded from bowel-movement counts.
- [ ] 2.3 Implement completeness and explicit-zero representation — verify round-trip tests keep every state distinct and event presence does not imply full-day coverage.
- [ ] 2.4 Implement day-window and correction rules — verify midnight, agreed zone behavior, a skipped day and an edit crossing a day boundary.

## 3. Persistence (issue #13)

- [ ] 3.1 Confirm the SwiftData mapping, failure and migration policy in its ADR — verify accepted alternatives and first schema version are documented before production integration.
- [ ] 3.2 Implement local persistence — verify every daily payload, completeness state and history round-trips, including reopening a disk-backed test store.
- [ ] 3.3 Handle save failure without a false success — verify an injected write failure is shown and no unsaved fact appears persisted.
- [ ] 3.4 Add migration coverage before a persisted schema changes — verify a previous-schema fixture opens with identity and history preserved.

## 4. Recording and day review (issues #8-#11, #14)

- [x] 4.1 Build the four peer entry points and empty-state skeleton — verified by the two existing UI tests and merged PR #5; actual flows remain unchecked below.
- [ ] 4.2 Build the toilet form after agreeing its minimum fields and quick-save interaction — verify an XCUITest saves and retrieves an event with editable happened-at time.
- [ ] 4.3 Build the meal form after settling photos, supplement representation and required fields — verify accepted minimum-input scenarios save and can be reviewed without nutritional analysis.
- [ ] 4.4 Build the medication form after agreeing dose entry and required fields — verify actual time/dose round-trip and a partial dose receives no adherence judgement.
- [ ] 4.5 Connect the day list to storage with details, backfill markers and editing — verify selecting another day changes the data, edits retain history, and the empty state is actionable.
- [ ] 4.6 Implement deletion after agreeing retention and undo behavior — verify the deleted record leaves active lists/counts and other facts remain unchanged.
- [ ] 4.7 Verify largest text, VoiceOver and one-handed reachability — attach relevant captures and demonstrate all three recording flows remain completable.

## 5. Recording acceptance

- [ ] 5.1 Align the existing snapshot runtime and baselines — verify required comparisons execute rather than silently skip; record any unavailable comparison explicitly.
- [ ] 5.2 Provide development-signing and device-run instructions without committing credentials — verify a synthetic save, force-quit, relaunch and day-history exercise on the maintainer's phone.
- [ ] 5.3 Verify shared-evidence hygiene — a synthetic recording/edit/delete session exposes no health field values in logs and contains no conclusive product copy.

## Workflow follow-up

- M1 also requires add-biologic-schedule, add-objective-trends and cross-capability device acceptance.
- Resolve the real-data backup gate in the delivery plan before using real patient records.
- Verify this capability before syncing its spec; archive only after its own tasks and review are complete.
