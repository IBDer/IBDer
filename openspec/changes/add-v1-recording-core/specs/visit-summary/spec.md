# visit-summary — delta

## ADDED Requirements

### Requirement: Period summary of facts

The system SHALL produce a summary of a chosen period containing only recorded facts: events by type,
their counts and distributions, daily completeness, and the biologic schedule as planned versus
received.

#### Scenario: Generating a summary for three months
- **WHEN** the patient selects a period and requests a summary
- **THEN** the summary covers that period
- **AND** every figure is traceable to recorded events or explicit confirmations

### Requirement: Completeness is visible in the summary

The summary SHALL state, for the period, how many days were confirmed, partially recorded, or not
recorded. A summary SHALL NOT present figures over unrecorded days as if the days were symptom-free.

#### Scenario: A period with gaps
- **WHEN** half the days in the period have no records
- **THEN** the summary states that
- **AND** counts are shown against the recorded days only

### Requirement: No conclusions in the summary

The summary SHALL NOT contain a score, a severity or activity judgement, a probability, a trend
verdict, or treatment advice.

#### Scenario: Reading the summary
- **WHEN** the summary is displayed or exported
- **THEN** it contains no wording that characterises the patient's disease state

### Requirement: Two export forms

The system SHALL export the summary in a human-readable form and in a structured form. The structured
form SHALL be a **documented, versioned format**, and every record in it SHALL carry its identifier, its
event type, the time it happened, the time it was recorded, and its completeness value.

#### Scenario: Exporting for a clinician
- **WHEN** the patient exports the summary
- **THEN** a readable document is produced
- **AND** a structured file is produced that declares its format version
- **AND** every record in that file carries id, type, happened-at, recorded-at and completeness

### Requirement: Sharing is an explicit act

Export and sharing SHALL be initiated by the patient, and the system SHALL state that a shared file
leaves the app's protection.

#### Scenario: Sharing a file
- **WHEN** the patient shares an exported summary
- **THEN** the system has warned beforehand that the file leaves the app's protection
