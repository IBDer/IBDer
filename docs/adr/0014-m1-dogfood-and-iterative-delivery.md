# ADR-0014: M1 is a personal MVP delivered through small OpenSpec changes

- **Status**: Accepted for scope and working method; slice-level product choices remain open
- **Date**: 2026-10-20
- **Source**: Maintainer direction in [issue #24](https://github.com/IBDer/IBDer/issues/24)
- **Supersedes**: ADR-0001's delivery packaging and ADR-0005's fixed gates and one-change/one-PR rule

## Context

The maintainer defined M1 as daily medication, meal and toilet recording; biologic kinds,
appointments and reminders; and week, month, six-month and year trends, for personal dogfooding.
Fields, screens and interactions must be discussed and revised during implementation.
The previous three-day recording check was an acceptance exercise, not the whole MVP.

## Decision

Keep OpenSpec. Separate independently verifiable capabilities instead of carrying all of v1 in one
change. Scope and completion checks live in [the delivery plan](../process/delivery-plan.md).
Daily confirmation and visit-summary export remain planned follow-ups rather than implicit M1 work.
Basic actual-infusion recording remains part of the biologic workflow under ADR-0001.

Agree on the current slice's observable behavior before implementing it; use prototypes and running
screens to refine it. Existing authorization counts. Ask about unresolved product choices affecting
that slice, and update its specs, design and tasks when the answer changes. A milestone outline does
not approve undisclosed fields, calculations or layouts.

One capability change may use several focused implementation PRs. Synchronise only verified behavior
into main specs; archive a change after its own requirements are implemented and reviewed. Release tags
represent releases, not every implementation slice.

## Consequences

- Keep the recording change name so merged work remains traceable, narrowing it to daily records and
  persistence. Move the other capability plans without claiming implementation.
- Apple Fitness is a reference for trend time navigation and browsing; metric definitions, chart forms
  and aggregation details are settled in their implementation slices.
- The three-day device exercise supplements capability tests; synthetic fixtures verify long periods.
- This decision grants no data-protection exception. The existing backup-before-real-data prerequisite
  remains in force until delivered or explicitly revised by the maintainer.
- Public distribution and clinical wording decisions remain separate from personal MVP acceptance.

## Alternatives

Migrating to Spec Kit would replace the existing artifact conventions without resolving the oversized
change or stale board. Both tools allow evolving requirements. Keep the integrated tool and fix the
delivery granularity instead; reconsider migration only for a demonstrated workflow need.

References: [OpenSpec iteration](https://github.com/Fission-AI/OpenSpec/blob/main/docs/editing-changes.md)
and [Spec Kit evolution](https://github.com/github/spec-kit/blob/main/docs/guides/evolving-specs.md),
checked 2026-10-20.
