# biologic-schedule — delta

## ADDED Requirements

### Requirement: Three separated layers

The system SHALL keep the biologic plan, pending appointments, and infusion records as three separate
things. A plan SHALL NOT be displayed as a completed treatment, and an appointment SHALL NOT be
displayed as a fact.

#### Scenario: A scheduled appointment on the home screen
- **WHEN** an appointment is due in the future
- **THEN** it is displayed as a plan or pending item
- **AND** it is not counted as a received dose

### Requirement: The plan reflects the patient's care team's instructions

The system SHALL let the patient enter a biologic plan from instructions they already have. The system
SHALL NOT recommend a regimen, a dose, an interval, or a substitution.

#### Scenario: Entering a plan
- **WHEN** the patient enters a drug, a route, and an interval
- **THEN** the values are stored as the patient's own record of their arrangement
- **AND** no default regimen is offered

### Requirement: Appointment lifecycle

A pending appointment SHALL be confirmable, reschedulable, and cancellable, and a reschedule SHALL
preserve the original arrangement in history.

#### Scenario: Rescheduling
- **WHEN** the patient moves an appointment to a new date
- **THEN** the appointment shows the new date
- **AND** the previous date remains in history

### Requirement: Infusion record

An infusion record SHALL capture what actually happened, including the actual date, and MAY carry the
site, the drug, the dose, and a note. The record SHALL retain its link to the appointment it came from
when one exists. After-the-fact notes such as tolerability SHALL be recordable.

#### Scenario: Recording a completed infusion
- **WHEN** the patient records an infusion that happened
- **THEN** the linked appointment is marked as done
- **AND** the infusion record is stored as a fact

### Requirement: Reminders

The system SHALL derive local reminders from pending appointments and tasks. A reminder SHALL NOT, by
itself, create a fact, and completing a reminder SHALL require an explicit confirmation.

#### Scenario: A reminder is not a dose
- **WHEN** a reminder fires and the patient dismisses it
- **THEN** no medication or infusion record is created

#### Scenario: Confirming from a reminder
- **WHEN** the patient confirms from the reminder that the dose was taken
- **THEN** a fact is created only from that explicit confirmation

### Requirement: No treatment advice around the schedule

The system SHALL NOT advise on missed doses, dose adjustment, interval changes, or whether to delay
treatment.

#### Scenario: A missed appointment
- **WHEN** an appointment passes without a record
- **THEN** the system shows it as unrecorded
- **AND** it offers no instruction about what to do
