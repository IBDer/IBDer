# ADR-0001: v1 records four kinds of facts — three peer daily event types plus the biologic schedule

- **Status**: Accepted for the original v1 direction; delivery scope and packaging superseded by [ADR-0014](0014-m1-dogfood-and-iterative-delivery.md)
- **Date**: 2026-10-11, revised 2026-10-12

## Context

IBD self-management is not one activity. A patient may record toilet events, meals (including oral
nutritional supplements), medication actually taken — and, on a longer rhythm, a biologic infusion
that was planned, scheduled, and finally received.

Two earlier framings were wrong. They are recorded here so they are not reintroduced:

1. **"Toilet event first."** The first draft made the toilet event *the* v1 feature. That came from an
   interaction-cost argument (recording must be cheap), not from a claim about importance.
   The maintainer rejected it: **the daily event types are equally important.**
2. **"Defer the biologic workflow."** The second draft deferred it for modelling cost. The maintainer
   rejected that too: **the infusion workflow is a basic function**, not a later nice-to-have.

## Decision

v1 is a **multi-type daily event recorder with the biologic schedule built in**:

1. **Daily event types, as peers** — shared event envelope, type-specific fields:
   - `ToiletEvent`
   - `MealRecord` (including oral nutritional supplement)
   - `MedicationRecord` (what was actually taken)
2. **Biologic schedule** — the one part that needs three layers, kept explicitly separate so they
   never impersonate each other (see CONTEXT.md):
   - `BiologicPlan` — the arrangement the patient entered from their care team's instructions
   - `InfusionAppointment` — one pending appointment; confirmable, reschedulable, cancellable
   - `InfusionRecord` — one infusion that actually happened
3. **Daily confirmation** closing the day across all recorded types (`RecordCompleteness`).
4. **Visit summary** export (human-readable + structured).

Still excluded from v1: food–symptom correlation, any score, any AI assistance (ADR-0004, ADR-0009).

"One tap" survives as a **design constraint on every entry path** — it is not a statement about priority.

## Consequences

- The first OpenSpec change covers: event kernel (three daily types) + biologic schedule (three layers)
  + daily confirmation + visit summary. It is a large first change; it is sliced **inside** the change
  rather than postponed.
- The data model uses a shared envelope for daily events and a strict three-layer separation for the
  schedule; adding a type later must not reshape the schema.
- Reminders are generated from appointments and tasks and are **never** turned into facts
  automatically (the plan/fact boundary in AGENTS.md §3).
- Infusion-related copy needs clinical review before public distribution.
