# event-recording — delta

## ADDED Requirements

### Requirement: Peer event types

The system SHALL record daily events of three types, treated as peers: toilet events, meals
(including oral nutritional supplements), and medication actually taken. No type SHALL be presented as
the primary purpose of the product.

#### Scenario: Recording any type costs one tap to start
- **WHEN** the patient is on the recording screen
- **THEN** each of the three event types is reachable in one tap
- **AND** the time of the event defaults to now and can be changed

#### Scenario: A type is added later without reshaping history
- **WHEN** a new event type is introduced in a future change
- **THEN** previously recorded events remain readable and unchanged

### Requirement: Shared event envelope

Every recorded event SHALL carry: the time it happened, the time it was recorded, its type, its
record completeness, and its edit history. The time it happened and the time it was recorded SHALL be
separate values.

#### Scenario: Backfilling an event
- **WHEN** a patient records an event that happened earlier
- **THEN** the event keeps both timestamps
- **AND** the interface marks it as backfilled

#### Scenario: Editing an event
- **WHEN** a patient edits a recorded event
- **THEN** the previous values remain in the edit history

### Requirement: Toilet event fields

A toilet event SHALL distinguish what was passed: stool, blood or mucus only, urge without passing
anything, or uncertain. An urge without passing anything SHALL NOT be counted as a bowel movement.

#### Scenario: Recording an urge-only event
- **WHEN** the patient records an event and selects "urge without passing anything"
- **THEN** the event is stored
- **AND** it is excluded from bowel-movement counts

### Requirement: Meal record fields

A meal record SHALL capture that a meal or snack happened, and MAY carry a short description, a photo,
and a note. A meal record SHALL NOT be required to carry nutritional analysis.

#### Scenario: Recording a meal with only a photo
- **WHEN** the patient attaches a photo and no description
- **THEN** the meal record is saved

### Requirement: Medication record fields

A medication record SHALL capture what was actually taken, with the actual time and the actual dose.
It SHALL NOT evaluate adherence, and it SHALL NOT suggest a missed dose be made up.

#### Scenario: Recording a partial dose
- **WHEN** the patient records a dose different from the planned one
- **THEN** the actual value is stored
- **AND** no adherence judgement is displayed

### Requirement: Daily confirmation

The system SHALL let the patient close a day by confirming totals and the most severe symptoms, and
SHALL record a completeness value for each event type. The system SHALL NOT compute the confirmation
from events alone.

#### Scenario: Confirming a day with no records
- **WHEN** the patient confirms a day on which nothing was recorded
- **THEN** the patient can explicitly state zero events
- **AND** that statement is distinguishable from "not recorded"

#### Scenario: Correcting an auto-filled total
- **WHEN** the patient changes the total proposed from recorded events
- **THEN** both the event count and the confirmed total are stored

### Requirement: Completeness semantics

The system SHALL distinguish, for every day and event type: recorded every one, totals accurate but not
itemised, approximate, and not recorded. Missing data SHALL NOT participate in any statistic as zero.

#### Scenario: A skipped day in a trend
- **WHEN** a period contains a day with no records and no confirmation
- **THEN** the trend shows a gap for that day
- **AND** the gap is not rendered as zero events

### Requirement: Explicit zero is not absence

Where a value can legitimately be zero, the system SHALL allow the patient to state zero explicitly,
and that state SHALL be stored and displayed differently from a missing value.

#### Scenario: No blood observed versus not answered
- **WHEN** the patient confirms "no blood" on a day
- **THEN** the value reads as explicitly none
- **WHEN** the patient does not answer
- **THEN** the value reads as not recorded
