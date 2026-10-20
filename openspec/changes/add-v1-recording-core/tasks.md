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

- [x] 2.1 Agree local-day/time-zone, backfill and edit semantics; update this spec/design with examples — recorded in design.md "Slice decisions"; boundary scenarios in RecordSemanticsTests.
- [x] 2.2 Implement the envelope and typed daily payloads — RecordSemanticsTests: both timestamps, an edit keeping the previous value, urge-only excluded from the count.
- [x] 2.3 Implement completeness and explicit-zero representation — every state round-trips; Reading keeps unknown apart from a known zero; a day's completeness is never inferred.
- [x] 2.4 Implement day-window and correction rules — midnight belongs to the new day; 23:59 and 00:01 fall in different ranges; a day only returns its own records.

## 3. Persistence (issue #13)

- [x] 3.1 Confirm the storage engine, failure and migration policy in its ADR — ADR-0015 records the archive, the rejected alternatives and schema version 1.
- [x] 3.2 Implement local persistence — FileEventStoreTests reopen a disk-backed store and read the record back with its payload.
- [x] 3.3 Handle save failure without a false success — an injected write failure throws, the record is absent, and no file is written.
- [x] 3.4 Pin the archive format before it changes — a written-out version 1 fixture opens with its identifier and revision history; a newer schema is refused rather than discarded.

## 4. Recording and day review (issues #8-#11, #14)

- [x] 4.1 Build the recording entry points, the tab bar and the empty-state skeleton — three peer entries (toilet, meal, medication) and the empty day, verified by UI tests.
- [x] 4.2 Build the toilet form — four outcomes, then Bristol, blood and perianal sensation; an XCUITest saves and reads the fact back on that day.
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
