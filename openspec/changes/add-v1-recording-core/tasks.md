# Tasks: v1 recording core

Every task states how it is verified. Tests use synthetic data only (AGENTS.md §4).

## 1. Project skeleton

- [ ] 1.1 Create the iOS app target (SwiftUI, iOS 18+) with the folder layout from docs/engineering/architecture.md — verify: builds for the iOS Simulator and runs with an empty root view
- [ ] 1.2 Add the DesignSystem token module with the values from docs/design/design-tokens.md — verify: a unit test asserts every token equals the documented value
- [ ] 1.3 Add SwiftLint/SwiftFormat configuration and wire it into CI — verify: CI fails on a deliberately introduced force-unwrap
- [ ] 1.4 Add the test targets and a CI job that runs unit tests on a simulator — verify: CI is green on an empty test suite

## 2. Domain model (no UI, no persistence)

- [ ] 2.1 Implement the event envelope value types (happened-at, recorded-at, type, completeness, edit history) — verify: unit tests cover backfill, edit, and history retention
- [ ] 2.2 Implement the three daily event payloads (toilet, meal, medication) — verify: unit tests assert an urge-only event is excluded from bowel-movement counts
- [ ] 2.3 Implement the completeness enum and the explicit-zero value — verify: unit tests assert zero and not-recorded are different values and neither serialises to the other
- [ ] 2.4 Implement the three schedule entities with links and history — verify: unit tests assert a reschedule keeps the previous arrangement and that a dismissed reminder creates no fact
- [ ] 2.5 Implement date-window rules for the local day, including midnight crossing — verify: unit tests cover midnight, a skipped day, and a day with an edited event

## 3. Persistence

- [ ] 3.1 Model the entities in SwiftData and write the mapping from domain types — verify: an in-memory store round-trips every entity with completeness and history intact
- [ ] 3.2 Prove the no-null-conflation rule at the storage layer — verify: a test writes every completeness state and reads back the same value
- [ ] 3.3 Record the persistence ADR required by ADR-0002 — verify: docs/adr contains the SwiftData decision with the rejected alternatives
- [ ] 3.4 Add schema-migration coverage before the schema changes twice — verify: a test opens a store created with the previous schema shape

## 4. Recording a day (event-recording)

- [ ] 4.1 Build the recording screen with the three peer entry points — verify: an XCUITest records one event of each type in one tap each
- [ ] 4.2 Build the day view with the event list and the empty state — verify: the empty state names the next action rather than showing a bare illustration
- [ ] 4.3 Build event detail and edit — verify: editing keeps both timestamps and shows the backfill marker
- [ ] 4.4 Build the daily confirmation with totals, worst symptoms, and per-type completeness — verify: an XCUITest confirms a day with zero events and reads it back as explicit zero
- [ ] 4.5 Make the primary recording action reachable one-handed at the largest Dynamic Type — verify: manual check at the largest type size, recorded in the PR

## 5. Biologic schedule

- [ ] 5.1 Build plan entry — verify: no default regimen, dose, or interval is offered anywhere in the flow
- [ ] 5.2 Build the appointment list and lifecycle (confirm, reschedule, cancel) — verify: an XCUITest reschedules and sees both dates
- [ ] 5.3 Build infusion recording linked to an appointment — verify: recording marks the appointment done and stores the record as a fact
- [ ] 5.4 Build after-the-fact tolerability notes — verify: a note can be added after the infusion without changing its date

## 6. Reminders

- [ ] 6.1 Schedule local notifications from pending appointments and tasks — verify: a test asserts one notification per pending item and none for completed ones
- [ ] 6.2 Make dismissal create nothing and confirmation create the fact — verify: an XCUITest dismisses a reminder and asserts no record exists

## 7. Visit summary

- [ ] 7.1 Generate the period summary from facts and completeness — verify: a unit test over a synthetic period with gaps states the gaps and counts only recorded days
- [ ] 7.2 Export the human-readable form — verify: the exported document opens and contains no conclusion wording
- [ ] 7.3 Export the structured form with per-record provenance — verify: the file parses and every figure maps back to a record
- [ ] 7.4 Warn before sharing — verify: the warning appears before the share sheet in an XCUITest

## 8. Verification and quality gates

- [ ] 8.1 Accessibility pass: VoiceOver labels, contrast, Reduce Motion, largest type — verify: docs/design/accessibility.md checklist completed in the PR
- [ ] 8.2 Confirm no surface computes a score, severity, or verdict — verify: a grep for the forbidden vocabulary in UI strings returns nothing (docs/engineering/naming.md)
- [ ] 8.3 Confirm no health content reaches logs — verify: the app log for a full synthetic session contains no field values
- [ ] 8.4 Confirm clinical wording is flagged for review — verify: every string about blood, pain, urgency, night waking, or care-seeking is listed in the PR as pending clinical review

## Workflow follow-up

- Gate 1 review of this change before any implementation starts.
- Gate 2 review of the implementation PR.
- Archive the change and tag it.
- Separate change: encrypted backup and restore (ADR-0003), required before real patient use.
