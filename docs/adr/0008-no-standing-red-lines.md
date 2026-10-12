# ADR-0008: No standing medical safety red lines for now; such features are decided one by one

- **Status**: Accepted
- **Date**: 2026-10-11

## Context

The organization's historical documents (the unverified `SAFETY.md`) list a set of medical safety red lines, and this repository's first version copied them verbatim into AGENTS.md. The maintainer decided: **no such red lines are set at this stage**, and the related constraints are added one by one as the App iterates.

## Decision

- This repository **currently sets no** medical safety red lines; the related constraints are decided one by one as features iterate, each recorded in its own ADR.
- But the following areas **must first be explicitly decided by a human maintainer before implementation**, and must not be done first and asked about afterwards:
  diagnosis / individualized treatment recommendations / remote consultation and emergency triage; disease activity scores and conclusive outputs such as "remission, active, relapse"; causal statements between food and symptoms; patient community UGC; clinical scale names, wording, graphics, and translations.
- The test is one sentence: **is the output "a fact the patient recorded", or "a conclusion the product itself reached".**

## Rationale

Constraints and features are **asymmetric**: features can be added later, while crossing a line means "borrowing against the future" — medical device classification, platform review outcomes, and patient trust are all hard to revoke after the fact. So it is not written as a standing clause, but a "decide first, implement second" gate is kept.

This gate **forbids no feature**; it only requires asking once before doing it.

## Consequences

- Features in the areas above are normal product decisions, not a forbidden list.
- The first feature to touch each of these areas must carry an ADR in its own change.
- If standing red lines are wanted in the future, replace this decision with a new ADR.
