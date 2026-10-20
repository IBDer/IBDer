# Design: v1 recording core

## Context

See `proposal.md` — Why. The repository has no application code yet: this is the change that creates
the app. Constraints that shape the design, and where they come from:

- Local-first, no account, no server (ADR-0002, ADR-0003).
- No score, severity, or verdict in any read path (ADR-0009).
- Plan, appointment, and fact must never impersonate each other (CONTEXT.md).
- Identifiers come from CONTEXT.md; our visual language is ours, with Aidy as a structural reference
  only (ADR-0007, ADR-0012).
- Local storage technology is to be decided here and recorded as its own ADR.

## Goals / Non-Goals

**Goals**
- One schema that records four kinds of fact without letting any of them reshape the others.
- Completeness that survives storage, statistics, and export intact.
- A recording path short enough to use while unwell.

**Non-Goals (design level)**
- No synchronisation, no account, no multi-device story. Backup is a separate change.
- No derived metric, no correlation, no machine learning.
- No patient-community surface.

## Decisions

### D1. Shared event envelope with typed payloads

Daily events share one envelope — happened-at, recorded-at, type, completeness, edit history — and
carry a type-specific payload.

*Alternatives:* a table per type (duplication of the completeness and edit semantics, and drift between
types); a schemaless blob (loses the guarantee that completeness exists).

*Why:* the requirements that matter most (completeness, edit history, no-zero-conflation) are identical
across types. Keeping them in one place makes them impossible to implement inconsistently.

### D2. Completeness is an enum, never a null

Every day and event type carries one of: recorded every one, totals accurate but not itemised,
approximate, not recorded. "Explicit zero" is a value, not an absence.

*Alternatives:* nullable counts (the failure mode the requirements exist to prevent — a null rendering
as zero and reading as improvement).

*Why:* with a nullable count, every future surface has to remember not to treat null as zero. With an
enum, the type system forces the decision.

### D3. Three layers for the biologic schedule

`BiologicPlan`, `InfusionAppointment`, `InfusionRecord` are separate entities with explicit links and
history, not one row with a status field.

*Alternatives:* one appointment row whose status moves planned → done. Simpler, but it destroys the
distinction the requirements depend on: a reschedule must not overwrite the original arrangement, and a
dismissed reminder must not become a dose.

*Why:* the plan/fact boundary is a product promise, not an implementation detail.

### D4. Local-only persistence, SwiftData

Persist on device with SwiftData; the app has no network dependency.

*Alternatives:* SQLite via GRDB (more explicit control over migrations and queries, one dependency);
files plus an index (no query story); Core Data (older API surface for no benefit here).

*Why SwiftData:* first-party, minimal ceremony, and the model here is small and append-mostly. *Risk
accepted:* its migration story is younger than SQLite's, so the schema is kept additive and every
schema shape is captured in tests before adoption; if migration pain appears at the second schema
change, this decision is revisited in its own ADR.

### D5. Nothing derived is stored

The system stores facts and computes display values on read; it never stores a score, a rate, or a
verdict.

*Why:* a stored derived value is a promise about the past that the patient cannot correct, and storing
one is how a score feature gets introduced by accident.

### D6. Reminders through local notifications only

Pending appointments and tasks schedule local notifications. No server, no push.

*Why:* consistent with ADR-0002 and §4 of AGENTS.md, and sufficient for a single-device product.

### D7. Summary generation is deterministic

The visit summary is produced by a template that reads recorded facts and completeness. No model is
involved (ADR-0004), so the same period always yields the same summary.

*Alternatives:* a generative summary. Rejected: it would need the health content to leave the device and
it could phrase a conclusion.

### D8. Feature-first SwiftUI layout

Follow `AGENTS.md` §3: `Features/` by capability, `Domain/` free of UI and
persistence, `DesignSystem/` for tokens and components. The three capabilities of this change map to
three feature folders.

## Risks / Trade-offs

- **[Clinical wording is unverified]** → Any copy around blood, pain, urgency, night-time waking, or
  seeking care is treated as unreviewed until a clinician signs it off; it must not ship in a public
  build before that.
- **[Field set is a hypothesis]** → The clinical research is a lead, not a validated instrument; the
  schema keeps field semantics explicit so a later correction is a mapping change, not a rewrite.
- **[First change is large]** → It is sliced inside the change (see tasks.md) so each slice is
  independently verifiable; nothing is postponed that the product cannot work without.
- **[SwiftData migration]** → Schema kept additive; migration behaviour covered by tests before the
  second schema change.
- **[Reminder fatigue]** → Reminders are per pending item and user-owned; no streak, no nagging metric.

## Migration Plan

Greenfield: no data to migrate. Rollback for the change itself is "delete the app and the branch";
there is no released version and no stored data outside the developer's device.

## Open Questions

- Exact anchor wording for the symptom severities (blood, urgency, pain) — the set itself is fixed by
  the spec; only the wording is deferred to clinical review, because the schema stores the patient's
  selection rather than an anchor definition.
- Whether the daily confirmation is one screen or a sheet per event type — an interaction detail with
  no spec impact.
