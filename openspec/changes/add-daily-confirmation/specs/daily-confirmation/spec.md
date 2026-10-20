# daily-confirmation — delta

## Purpose

Capture the patient's explicit daily totals and symptom selections separately from the individual
records, retaining the meaning of missing answers and completeness.

## ADDED Requirements

### Requirement: Fixed symptom set

The daily confirmation SHALL ask for the worst severity of a **fixed, enumerated symptom set**:
abdominal pain, stool urgency, visible blood, and waking from sleep because of bowel symptoms. The
patient MAY switch off items they do not track. A symptom outside the set SHALL NOT be added ad hoc, and
the set SHALL be versioned so a later change is a mapping rather than a rewrite.

#### Scenario: Asking about symptoms
- **WHEN** the patient opens the daily confirmation
- **THEN** every enabled symptom in the fixed set is asked about
- **AND** each one can be left as "not recorded" instead of being forced to a value
### Requirement: Daily confirmation

The system SHALL let the patient close a day by confirming totals and, for each enabled symptom in the
fixed set, its worst severity. It SHALL record a completeness value for each event type. The system
SHALL NOT compute the confirmation from events alone.

#### Scenario: Confirming a day with no records
- **WHEN** the patient confirms a day on which nothing was recorded
- **THEN** the patient can explicitly state zero events
- **AND** that statement is distinguishable from "not recorded"

#### Scenario: Correcting an auto-filled total
- **WHEN** the patient changes the total proposed from recorded events
- **THEN** both the event count and the confirmed total are stored

### Requirement: Confirmation preserves independent evidence

A daily confirmation SHALL retain its local day, patient-confirmed totals and per-type completeness
without replacing the underlying events. Zero and an unanswered value SHALL remain different. Later
editing of an event SHALL NOT silently rewrite the patient's previous statement.

#### Scenario: Recording an explicit zero
- **WHEN** the patient explicitly confirms zero for a type
- **THEN** that statement persists as zero and is distinguishable from an unanswered total

#### Scenario: Editing an event after confirmation
- **WHEN** a contributing event is edited after the day was confirmed
- **THEN** the patient's original confirmation remains identifiable separately from the event count
