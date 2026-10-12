# Proposal: v1 recording core

## Why

A patient living with IBD accumulates four kinds of facts — what they passed, what they ate, what they
took, and which biologic dose they received — across a day and across a treatment cycle. Today those
facts live in memory, in chat messages, and in paper, so the appointment conversation starts from
nothing. Existing trackers either force one form for everything or turn the record into an assessment
of the patient; both fail the same person at the same moment.

This change builds the recording core that the rest of the product depends on. It is the first change
in the repository and it defines what the app is: a recorder of facts that stays honest about what is
missing.

## What Changes

- Introduce **daily event recording** for three peer types — toilet events, meals (including oral
  nutritional supplements), and medication actually taken — on a shared event envelope.
- Introduce **daily confirmation**: the patient closes a day, and the system records how complete each
  event type was instead of assuming missing means none.
- Introduce the **biologic schedule** in three explicitly separate layers: the plan the patient
  entered, one pending appointment, and the infusion record that actually happened.
- Introduce **local reminders** derived from pending appointments and tasks.
- Introduce the **visit summary**: a chosen period exported for the patient to read or share.
- Nothing in the read path computes a score, a severity, or a verdict (ADR-0009).
- **Not in this change**: encrypted backup and restore (ADR-0003) lands as a separate change and is a
  release blocker before real patient use; food–symptom correlation; any AI assistance (ADR-0004);
  patient-community features.

**All four kinds of fact carry equal weight** (ADR-0001). The capability split below is about *shape*,
not priority: the three daily types share one event envelope, while the biologic schedule needs three
separated layers. No type is the product's main feature, and none is deferred.

## Capabilities

### New Capabilities

- `event-recording` — recording a day's facts across three peer event types, the daily confirmation
  that closes the day, and the completeness semantics that keep missing data from reading as absence.
  The three types are peers of the biologic schedule too; the split is by data shape.
- `biologic-schedule` — the plan / appointment / record separation for biologic treatment, reminders
  derived from it, and the rule that a reminder never becomes a fact on its own.
- `visit-summary` — producing a period summary a patient can read and share, and what such a summary
  must never claim.

### Modified Capabilities

None. This is the first change; `openspec/specs/` is empty.

## Impact

- **New application**: an iOS app (ADR-0002). No existing code to migrate — the archived Flutter
  project is not a source of requirements (see docs/inherited-documents.md).
- **Data**: local only, no account, no server. Field-level semantics come from the clinical research
  as *hypotheses pending clinical review*, not as validated instruments.
- **Copy**: any wording around blood, pain, urgency, night-time waking, or seeking care needs clinical
  review before public distribution.
- **Dependencies**: none that transmit health data off the device (AGENTS.md §4).
- **Testing**: synthetic data only. The completeness and date-window rules are the primary unit-test
  targets.
