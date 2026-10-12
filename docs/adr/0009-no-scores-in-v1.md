# ADR-0009: The first version outputs no disease activity score and copies no scale items

- **Status**: Accepted
- **Date**: 2026-10-12

## Context

Two clinical research documents take **opposite** positions on the same matter:

- `ibd-clinical-wiki` §5.3 / §16.2: do not copy the items, anchors, weights, or thresholds of Mayo / SCCAI / CDAI / HBI / PRO2; do not automatically infer scores or threshold judgments.
- `clinical-measures-and-design-patterns` §6.1 / §6.2: requires "automatic derivation of a daily PRO-2, a short SCCAI, and an approximate HBI", and gives the threshold "clinical remission < 5 points"; §6.2 also requires "anchor wording copied verbatim from the scale's prevailing version".

A comparable product, Aidy, adopts the latter (official description: "Modified Harvey-Bradshaw Index for Crohn's and SCCAI for UC, calculated automatically").

## Decision

The first version **presents only the raw facts recorded by the patient and objective statistics** (counts, distributions, time trends):

- it computes and displays no disease activity score or its thresholds;
- it does not name patient-reported items using names such as HBI / SCCAI / Mayo / CDAI / PRO2;
- it copies no scale's items, anchors, or weight wording;
- it outputs no conclusions such as "remission / active / relapse / needs more medication".

## Rationale

1. Symptoms and endoscopic inflammation do not correspond one-to-one; Chinese guidelines require a comprehensive assessment combining symptoms, laboratory results, and endoscopy, and STRIDE-II likewise separates symptoms, inflammatory markers, and endoscopic targets.
2. Once a score or a threshold judgment is output, the software's **intended use** may be determined to be disease monitoring or diagnostic aid, entering the scope of medical device regulation — this is a classification question, not a feature question.
3. Irreversibility: presenting facts only → derived scores can be upgraded at any time; the reverse cannot retract external commitments and regulatory facts that have already formed.

## Consequences

- The **affirmative recommendations** in §1.1–§1.3, §6.1, and §6.2 of `clinical-measures-and-design-patterns` **do not apply to the first version** (a ruling note has been added at the head of that document, and its body is retained for the record).
- If score features are to be built in the future, they require: a separate change + a new ADR + clinical validation + scale rights verification + a medical device classification argument.
- The words "activity", "remission", "relapse" and the like must not appear in the first version's interface copy or acceptance criteria.
