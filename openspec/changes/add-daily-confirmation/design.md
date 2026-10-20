# Design: daily confirmation follow-up

## Context

The unimplemented daily-confirmation requirements moved here from the recording bundle. See
proposal.md. This M2 hypothesis is revisited after personal dogfooding, not required for M1 charts.

## Goals / Non-Goals

Keep patient-confirmed totals distinct from event counts and missing answers distinct from zero.
Do not couple basic recording to completion of a daily review screen.

## Decisions

- Preserve the original fixed, versioned symptom set and explicit per-type completeness contract.
- Store the patient's statement separately from the event list. Later event edits must not silently
  rewrite it. Alternative: derive confirmation entirely from events, losing independent evidence.
- Read the recording capability's facts and map them into proposed totals, which the patient can change.

## Risks / Trade-offs

- [Feature may be unnecessary or too burdensome] -> Revisit the product need before its first slice;
  an agreed scope change revises this proposal instead of pretending it was implemented.
- [Clinical wording is unresolved] -> Keep issue #16 separate; settle scale shape before storage and
  complete clinical wording review before public distribution.

## Slice decisions

The confirmation interaction, enabled symptoms and severity representation remain subject to the
maintainer's decision before implementation. This relocation does not approve any clinical wording.
