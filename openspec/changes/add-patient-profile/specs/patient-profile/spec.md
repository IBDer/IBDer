# patient-profile — delta

## Purpose

Hold the few facts about the patient that the app needs, ask for them once, and reuse them without
turning them into a judgement.

## ADDED Requirements

### Requirement: A profile of self-reported facts

The system SHALL store a height, a weight, a diagnosis, a stated disease state, a set of current
treatments and a set of known complications. Every field SHALL be optional.

#### Scenario: Nothing filled in
- **WHEN** the patient skips every question
- **THEN** the app still records events
- **AND** no screen claims the profile is complete

### Requirement: Onboarding is skippable

The first launch SHALL offer three pages — body, disease, treatment — and every page SHALL offer a way
to move on without answering.

#### Scenario: Skipping the disease page
- **WHEN** the patient chooses not to say which disease they have
- **THEN** the next page opens
- **AND** the profile keeps that field empty rather than guessing

### Requirement: The disease state is what the doctor said

The system SHALL ask for the doctor's current assessment, offering remission, active and unsure, with
unsure preselected. The answer SHALL be stored and displayed and SHALL NOT be used in any calculation.

#### Scenario: Unsure
- **WHEN** the patient leaves the default
- **THEN** the profile records that they are unsure
- **AND** nothing derived from it appears anywhere

### Requirement: Treatment is a set

The system SHALL allow more than one current treatment at once, from: biologic, oral medication,
exclusive enteral nutrition, partial enteral nutrition, other diet, none.

#### Scenario: Two treatments at once
- **WHEN** the patient selects a biologic and partial enteral nutrition
- **THEN** both are stored and both are shown

### Requirement: Complications are broad groups

The system SHALL offer the groups perianal, skin, joints, eyes, mouth ulcers, liver and biliary, and
anaemia or nutrition, and SHALL NOT offer a specific diagnosis the patient cannot confirm.

#### Scenario: A perianal complication
- **WHEN** the patient selects the perianal group
- **THEN** the profile records the group
- **AND** the app does not name a fistula, an abscess or a fissure on their behalf

### Requirement: Weight is only a number

The system SHALL store weight in kilograms and SHALL NOT derive, score or compare it.

#### Scenario: Weight is reused
- **WHEN** a biologic plan needs a weight for a weight-based dose
- **THEN** it reads the stored weight and shows when that weight was entered
- **AND** the patient can replace it for that calculation

### Requirement: The profile survives relaunch and is editable

The profile SHALL be stored on the device and SHALL be editable from the settings tab after onboarding.

#### Scenario: Editing later
- **WHEN** the patient changes their weight from the settings tab
- **THEN** the new value survives relaunch
- **AND** onboarding does not run again
