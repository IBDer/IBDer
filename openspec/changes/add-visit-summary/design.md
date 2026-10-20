# Design: visit summary follow-up

## Context

See proposal.md. The original summary requirements are relocated unchanged; no generator or export
implementation exists. This is a separate M2 capability rather than part of M1 recording.

## Goals / Non-Goals

Produce a reproducible view of facts and completeness without modifying the source records. Backup
and restore have a separate purpose and cannot be replaced by a clinician-facing export.

## Decisions

- Use a deterministic template over the selected period, with source identities retained for figures.
  Alternative: generated narrative introduces unverifiable interpretations and a new data dependency.
- Produce human-readable and documented, versioned structured output from the same selected facts.
- Make sharing explicit and warn before the file leaves the app's protection.

## Risks / Trade-offs

- [Missing days appear symptom-free] -> Test sparse periods and state data coverage explicitly.
- [Export formats diverge] -> Verify both outputs against the same synthetic source period.

## Slice decisions

Discuss summary layout, readable format and structured schema before the export slices. Preserve the
format version and provenance guarantees as the presentation evolves.
