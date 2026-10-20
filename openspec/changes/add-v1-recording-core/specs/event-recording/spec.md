# event-recording — delta

## Purpose

Record daily facts with their provenance and completeness, preserving them through edits, local storage and day-based review.

## ADDED Requirements

### Requirement: Peer event types

The system SHALL offer medication, meal and toilet recording as peers, each reachable in one tap from
the recording entry points. Event time SHALL default to now and be editable. These flows SHALL coexist
with the biologic recording capability without implying a priority between types.

#### Scenario: Starting a daily record
- **WHEN** the patient chooses any daily type
- **THEN** its recording flow opens from the shared entry points
- **AND** its event time can be changed before saving

### Requirement: Shared event envelope

Every record SHALL retain a stable identifier, happened-at and recorded-at timestamps, its type,
completeness and edit history. Happened-at and recorded-at SHALL remain separate values.

#### Scenario: Backfilling an event
- **WHEN** the patient records an earlier event
- **THEN** both timestamps are retained
- **AND** the interface identifies it as backfilled

#### Scenario: Editing an event
- **WHEN** the patient changes a stored record
- **THEN** previous values remain in history
- **AND** the original recorded-at timestamp is preserved

### Requirement: Toilet event fields

A toilet event SHALL distinguish stool, blood or mucus only, urge without passing anything, and
uncertain. An urge without passing anything SHALL NOT count as a bowel movement.

#### Scenario: Recording an urge-only event
- **WHEN** the patient saves an urge-only event
- **THEN** it is visible in the day's records
- **AND** it is excluded from bowel-movement counts

### Requirement: Meal record fields

A meal record SHALL capture that a meal or snack happened, including oral nutritional supplements.
Required fields and any photo support SHALL be explicitly agreed in the meal slice before production
implementation; this outline neither requires a photo-only flow nor excludes photos from M1.

#### Scenario: Saving the agreed minimum meal record
- **WHEN** the patient supplies the minimum fields agreed for the meal slice
- **THEN** the meal and its actual time are stored
- **AND** the flow does not require nutritional analysis

### Requirement: Medication record fields

A medication record SHALL capture what was actually taken, with actual time and dose. It SHALL NOT
evaluate adherence or advise making up a missed dose.

#### Scenario: Recording a partial dose
- **WHEN** the patient records a dose different from their plan
- **THEN** the actual value is saved without an adherence judgement

### Requirement: Completeness semantics

The system SHALL preserve the distinction between recorded every one, totals accurate but not
itemised, approximate and not recorded. Saving some events alone SHALL NOT imply a complete day.
Missing observations SHALL NOT participate in statistics as confirmed zero.

#### Scenario: A day with a partial history
- **WHEN** some records exist without an explicit completeness statement
- **THEN** the system shows recorded facts without asserting that the day is fully recorded

### Requirement: Explicit zero is not absence

An explicitly recorded zero SHALL remain distinct from missing data in storage and display. A future
daily confirmation may supply explicit totals; M1 SHALL NOT require that future screen to retain gaps.

#### Scenario: An unanswered value
- **WHEN** no observation or explicit zero exists for a value
- **THEN** it remains unknown rather than becoming a confirmed zero

### Requirement: Day view and record lifecycle

The system SHALL retrieve records for the selected local day, allow detail review, editing and
deletion, and show an actionable empty state. Deleted records SHALL leave active lists and counts;
the deletion and history-retention policy SHALL be agreed before that slice is implemented.

#### Scenario: Looking back at another day
- **WHEN** the patient selects an earlier day
- **THEN** the list shows that day's records under the agreed date policy
- **AND** a day without records offers a way to record rather than reusing today's samples

#### Scenario: Deleting a record
- **WHEN** the patient deletes a record
- **THEN** it is absent from the active day list and subsequent counts
- **AND** other records remain unchanged

### Requirement: Records survive restart

Saved records and their timestamps, completeness and history SHALL survive app termination and
relaunch. A failed write SHALL be reported as a failure rather than presented as a completed save.
Schema changes SHALL preserve previously saved records under the documented migration policy.

#### Scenario: Relaunching after a save
- **WHEN** the patient terminates and reopens the app after saving records on several days
- **THEN** those records and their provenance can still be retrieved by day

#### Scenario: A write fails
- **WHEN** storage rejects a save
- **THEN** the patient receives an error and the interface does not claim the record was saved

### Requirement: Accessible recording flows

The daily recording and review flows SHALL remain completable at the largest supported Dynamic Type
size, with labelled controls and reachable primary actions.

#### Scenario: Recording with large text
- **WHEN** the largest text size is enabled
- **THEN** the patient can complete each daily recording flow and review it without clipped essential controls
