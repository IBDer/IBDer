# Design: biologic scheduling

## Context

See proposal.md. No schedule implementation exists. The original three-layer design is retained while
its unimplemented requirements move here so M1 scheduling can be verified independently.

## Goals / Non-Goals

Keep patient-entered arrangements, pending appointments and actual doses distinct. Reuse the shared
persistence infrastructure without adding a backend or a drug-recommendation dependency.

## Decisions

- Use separate domain values for BiologicPlan, InfusionAppointment and InfusionRecord, linked by
  identity and history. Alternative: one mutable planned/done row, which erases the original arrangement.
- Persist kind identity on historical actual records so editing a current arrangement cannot rewrite
  the past. The kind-entry interaction remains a slice decision.
- Schedule device-local notifications from pending items. Isolate scheduling behind a small interface
  supporting a test adapter and the system notification adapter. Alternative: send notifications from
  views, which scatters reconciliation across screens.
- Reconcile stable notification identifiers after edits, cancellation, completion and relaunch. A
  scheduling failure is visible separately from whether the appointment was stored.
- An explicit actual-dose confirmation writes a fact and then reconciles appointment/reminder state;
  dismissing or skipping a pending item never writes a dose. Test repeat actions for duplication.

## Risks / Trade-offs

- [Denied permission or notification scheduling failure] -> Retain the appointment and expose reminder
  availability; do not promise guaranteed delivery by the operating system.
- [Drug changes corrupt history] -> Test old and new kinds across the arrangement and actual records.
- [Recurrence expands scope] -> Discuss single versus recurring scheduling before implementing it.

## Slice decisions

Agreed with the maintainer on 2026-10-20, before implementation:

- **Catalogue, not a recommendation engine.** Six products ship with the regimen printed in their
  label: infliximab, vedolizumab, adalimumab, risankizumab, ustekinumab, guselkumab. The text comes
  from the label and is shown as the label's text; the source and the date it was checked live in
  `docs/research/biologic-regimens.md`. A product outside the catalogue is entered by hand, and no
  regimen is invented for it.
- **A plan is a sequence of dated doses**, not one interval: three of the six change amount, route or
  spacing between induction and maintenance.
- **A calculated dose is a suggestion.** For a weight-banded label (infliximab 5 mg/kg, ustekinumab
  by band) the app may calculate from a weight the patient enters and name the band. The record keeps
  the amount the hospital actually prepared, which the patient confirms. This is the maintainer's
  decision, taken against the earlier "the app offers no regimen" rule; it is recorded here rather
  than slipped in.
- **Reminders**: two weeks, one week and one day before, each switchable.
- **Overdue is red.** A missed appointment shows the days passed in the alert colour. This is a
  deliberate, narrow exception to "never colour-as-verdict": the alert is about an appointment the
  patient asked to be reminded of, never about a symptom or a disease state.
- **Postpone one, or change the rule.** Moving one appointment asks for a short reason and leaves the
  spacing untouched. Changing the repeating interval requires a reason and starts from a stated dose.
- **Pre-infusion checklist**: a short list kept on the appointment (blood tests done and whatever else
  the patient adds), shown as outstanding rather than as an error, never blocking completion.
- **Dose is recorded.** The infusion record stores the amount given; it never stores "adherence".
