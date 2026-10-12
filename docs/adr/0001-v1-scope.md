# ADR-0001: v1 records multiple daily event types, and they are peers

- **Status**: Accepted — revised 2026-10-12
- **Date**: 2026-10-11, revised 2026-10-12

## Context

IBD self-management is not one activity. On a given day a patient may need to record toilet events,
meals (including oral nutritional supplements), medication actually taken, and biologic doses.
Treating any one of these as *the* first-version feature misrepresents both the product and the day.

The first draft of this ADR framed v1 as "toilet event (one tap) + daily confirmation + visit summary".
That framing came from an **interaction-cost** argument — recording has to be cheap — not from a claim
about importance. The maintainer rejected the framing: **the event types are equally important.**

## Decision

v1 is a **multi-type daily event recorder**, plus a confirmed daily review and an exportable summary:

1. **Event recording kernel**, with these types as peers:
   - `ToiletEvent`
   - `MealRecord` (including oral nutritional supplement)
   - `MedicationRecord` (what was actually taken)
2. **Daily confirmation** closing the day across all recorded types (`RecordCompleteness`).
3. **Visit summary** export (human-readable + structured).

Deferred — **not because they matter less**, but because they need more modelling:
- the biologic / infusion workflow (`BiologicPlan` → `InfusionAppointment` → `InfusionRecord`),
  which requires the plan/task/fact three-layer model;
- food–symptom correlation, scores, and any AI assistance (ADR-0004, ADR-0009).

"One tap" survives as a **design constraint on every event entry**, not as a statement about priority.

## Consequences

- The data model uses a **shared event envelope plus type-specific fields**, so adding a type later
  does not reshape the schema.
- Daily confirmation covers completeness across all types, not stool alone.
- The first OpenSpec change is scoped to: event kernel (three types) + daily confirmation + visit summary.
- ADR-0008 (decide before implementing) and ADR-0009 (no scores) are unaffected.
