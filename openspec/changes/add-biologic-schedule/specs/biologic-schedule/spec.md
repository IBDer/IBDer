# biologic-schedule — delta

## Purpose

Manage patient-entered biologic arrangements, pending appointments and reminders separately from the doses actually received.

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

The system SHALL let the patient choose a biologic from a verified catalogue, or enter one themselves.
A catalogue regimen SHALL be shown as the label's text, never as the app's advice, and every value
SHALL be changeable before the plan is saved.

#### Scenario: Starting from the label's regimen
- **WHEN** the patient picks a biologic from the catalogue
- **THEN** the induction dates, amounts and routes from the label are offered as a starting point
- **AND** each of them can be changed before the plan is saved

#### Scenario: A weight-based induction dose
- **WHEN** the patient enters a weight inside a label band
- **THEN** the matching amount is shown together with the band and the label it came from
- **AND** the patient can replace it with the amount the hospital prepared

#### Scenario: A drug that is not in the catalogue
- **WHEN** the patient's product is not listed
- **THEN** they can enter the name, route, amounts and dates themselves
- **AND** no regimen is invented for it

### Requirement: A calculated dose is a suggestion

Where a label dose depends on body weight, the system MAY calculate it from a weight the patient
enters, and SHALL name the band and the source it used. The amount stored in the record is the amount
actually given, confirmed by the patient.

#### Scenario: The calculation is replaced
- **WHEN** the hospital prepares a different amount from the calculated one
- **THEN** the patient's confirmed amount is what the record keeps

### Requirement: Appointment lifecycle

A pending appointment SHALL be confirmable, reschedulable, cancellable, or completed once the infusion
it produced is recorded. A reschedule SHALL preserve the original arrangement in history.

#### Scenario: Rescheduling
- **WHEN** the patient moves an appointment to a new date
- **THEN** the appointment shows the new date
- **AND** the previous date remains in history

### Requirement: Temporary postponement and a changed rule

The system SHALL distinguish moving one appointment from changing the repeating arrangement. Moving one
appointment SHALL offer a short reason — unwell, travel, waiting for a blood test — and SHALL leave the
repeating arrangement untouched. Changing the repeating arrangement SHALL require a reason and SHALL
apply only from a stated dose onward.

#### Scenario: Postponing one infusion
- **WHEN** the patient moves one appointment and gives a reason
- **THEN** only that appointment moves
- **AND** the following appointment keeps the original spacing

#### Scenario: Changing the interval for good
- **WHEN** the patient changes the repeating interval
- **THEN** a reason is required
- **AND** the change starts from the dose the patient chose, with earlier doses unchanged

### Requirement: Pre-infusion checklist

The system SHALL let the patient keep a checklist of what must happen before an infusion, including
whether the blood tests have been done, and SHALL show its state on the appointment without blocking
completion.

#### Scenario: Checking before going in
- **WHEN** the patient opens an upcoming appointment
- **THEN** the checklist items are visible and can be ticked
- **AND** an unticked item is shown as outstanding, not as an error

### Requirement: Infusion record

An infusion record SHALL capture what actually happened, including the actual date, and MAY carry the
site, the drug, the dose, and a note. The record SHALL retain its link to the appointment it came from
when one exists. After-the-fact notes such as tolerability SHALL be recordable.

#### Scenario: Recording a completed infusion
- **WHEN** the patient records an infusion that happened
- **THEN** the linked appointment is marked as done
- **AND** the infusion record is stored as a fact

### Requirement: Reminder schedule

The system SHALL schedule local reminders two weeks, one week and one day before a pending appointment.
Each lead time SHALL be switchable on its own. A reminder SHALL NOT, by itself, create a fact.

#### Scenario: The three reminders
- **WHEN** an appointment is confirmed for a date two weeks away
- **THEN** reminders are scheduled for two weeks, one week and one day before it
- **AND** turning one lead time off removes only that reminder

#### Scenario: An appointment is overdue
- **WHEN** the appointment date passes with no recorded infusion
- **THEN** the card says how many days have passed, in the alert colour
- **AND** nothing is recorded until the patient says what happened

### Requirement: Overdue is shown in the alert colour

An appointment whose date has passed without a recorded infusion SHALL be shown as overdue, with the
number of days passed, in the alert colour. This marks a missed appointment the patient asked to be
reminded about; it SHALL never mark a symptom or a disease state.

#### Scenario: Rescheduled before a reminder fires
- **WHEN** the appointment moves
- **THEN** the three reminders move with it
- **AND** no reminder for the old date remains

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

### Requirement: Recording an infusion costs one tap

Recording an infusion SHALL be reachable in one tap from the same recording entry points as the daily
event types, and SHALL be presented with the same weight.

#### Scenario: Recording an infusion
- **WHEN** the patient opens the recording entry points
- **THEN** recording an infusion is one of them
- **AND** the date defaults to today and can be changed

### Requirement: Pending task lifecycle

A pending task produced by a plan or an appointment SHALL have an explicit lifecycle — confirmed,
postponed, or skipped — and no transition SHALL turn it into a fact.

#### Scenario: Skipping a pending task
- **WHEN** the patient skips a pending task
- **THEN** the task is recorded as skipped
- **AND** no fact is created


### Requirement: Biologic kinds remain identifiable

The system SHALL retain the biologic kind entered or selected by the patient and identify it on the
relevant arrangement, appointment and actual record. Changing the current kind SHALL NOT silently
rewrite the kind associated with historical doses.

#### Scenario: Changing biologic kind
- **WHEN** the patient changes their current biologic kind
- **THEN** previously recorded doses keep their original kind
- **AND** future appointments reflect the explicitly updated arrangement

### Requirement: Reminder state follows appointments

Changing or cancelling an appointment SHALL update or remove its pending local reminders. Completing
an appointment SHALL remove obsolete pending reminders. Unchanged items SHALL NOT accumulate duplicate
notifications when the app relaunches.

#### Scenario: Rescheduling an appointment with a reminder
- **WHEN** the patient changes an appointment date
- **THEN** its obsolete reminder is removed and the pending reminder reflects the agreed new schedule

#### Scenario: Cancelling an appointment
- **WHEN** the patient cancels an appointment
- **THEN** its pending reminder is removed and no actual dose is created

### Requirement: Notification availability is visible

The system SHALL communicate when notification permission or scheduling failure prevents an
appointment reminder. The appointment SHALL remain available in the app even when reminders cannot
be delivered; permission denial SHALL NOT erase it or mark it complete.

#### Scenario: Permission is denied
- **WHEN** the patient denies notification permission
- **THEN** the appointment is still saved and visible
- **AND** the app explains that its notification reminder is unavailable
