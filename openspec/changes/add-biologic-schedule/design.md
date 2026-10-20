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

Kind entry, optional fields, recurrence, reminder lead times and notification actions need product
feedback before their production slices. The outline fixes lifecycle guarantees, not those defaults.
