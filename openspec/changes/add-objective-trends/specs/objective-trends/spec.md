# objective-trends — delta

## Purpose

Browse factual statistics over short and long periods while retaining the provenance and missing-data
meaning of the underlying records.

## ADDED Requirements

### Requirement: Four time ranges

The system SHALL offer week, month, six-month and year ranges for M1 acceptance.
Each range SHALL identify its start and end dates and support browsing historical periods. Exact
calendar boundaries and aggregation buckets SHALL be agreed before implementing the range slice.

#### Scenario: Switching the range
- **WHEN** the patient selects each of the four ranges
- **THEN** the selected period and its recorded data are displayed
- **AND** the start and end dates can be determined from the interface

### Requirement: Defined factual metrics

Each displayed metric SHALL have an agreed definition, unit, counting rule and any denominator,
recorded in its acceptance scenarios before implementation. Metrics SHALL derive from actual records
or explicit patient statements; appointments alone SHALL NOT count as received doses.

#### Scenario: Reviewing a metric
- **WHEN** the patient views a trend figure
- **THEN** its meaning, unit and covered period are identifiable
- **AND** its calculation can be reproduced from the included records and any explicit confirmations

### Requirement: Coverage remains visible

Trend displays SHALL distinguish missing observations from explicit zero and show the coverage used
by a statistic. Recorded events alone SHALL NOT imply a fully observed day. Any average SHALL state
its denominator and SHALL NOT silently treat missing days as confirmed zero.

#### Scenario: A period has gaps
- **WHEN** some days in the selected period have no observations
- **THEN** those gaps remain identifiable
- **AND** any summary describes its recorded-data coverage

### Requirement: Short histories work in long ranges

Every time range SHALL remain usable when less than the whole period has been recorded. Unobserved
history SHALL remain unobserved rather than being invented or blocking the range selector.

#### Scenario: A new installation selects year
- **WHEN** only three days of records exist and the patient selects the year range
- **THEN** those records are displayed with the remaining coverage identifiable as unknown

### Requirement: Corrected facts update trends

Editing or deleting a record SHALL update affected statistics and detail consistently, including
moving a record between periods when its happened-at timestamp changes.

#### Scenario: Moving a record across a period boundary
- **WHEN** an edit changes a record's happened-at time to another period
- **THEN** the old period excludes it and the new period includes it under the agreed counting rule

#### Scenario: Deleting an included record
- **WHEN** an included record is deleted
- **THEN** subsequent trend figures and source detail both exclude it

### Requirement: Figures have inspectable source detail

The system SHALL let the patient inspect the recorded data behind a selected figure or bucket. The
interaction and granularity SHALL be refined with the maintainer, including accessible text for the
information conveyed by the chart.

#### Scenario: Inspecting a selected bucket
- **WHEN** the patient selects a trend bucket or its accessible equivalent
- **THEN** its dates and contributing recorded facts can be reviewed

### Requirement: Objective output without a confirmation dependency

M1 trends SHALL work without a daily-confirmation screen. They SHALL describe recorded facts without
inferring disease state, food causality or treatment advice. Apple Fitness is a navigation reference;
it SHALL NOT imply unagreed targets, health scores or achievement rules.

#### Scenario: Browsing before daily confirmation exists
- **WHEN** the patient has saved daily records but no daily confirmation
- **THEN** factual history remains available with its coverage limitations visible
- **AND** the app adds no clinical conclusion to that history
