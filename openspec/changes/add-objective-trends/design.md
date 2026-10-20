# Design: objective trends

## Context

See proposal.md. There is no trend code. The source is daily records and actual biologic facts;
appointments remain pending information. Daily confirmation is a later independent capability.

## Goals / Non-Goals

Make calculations reproducible and corrections visible across all ranges. Borrow Apple Fitness's
browsing approach as a reference without assuming rings, targets or a particular chart design.

## Decisions

- Put date windows, buckets and aggregation in pure domain logic with injected calendar/time-zone and
  clock inputs. Alternative: aggregate inside SwiftUI, which makes period boundaries hard to verify.
- Read active facts and coverage; calculate display statistics rather than persist authoritative
  derived totals. Alternative: stored totals can go stale after an edit or a deletion.
- Keep source record identities available for each displayed bucket so detail and aggregate agree.
- Define the first metric with the maintainer, build it end to end, then extend to agreed metrics and
  all four ranges. Use synthetic year-long fixtures, leap dates and sparse histories from the start.
- M1 must describe observed data even without explicit daily totals. Do not infer a fully observed
  day from one saved event; future confirmation can add evidence through a subsequent change.

## Risks / Trade-offs

- [Unknown metric semantics] -> Settle definition, units, denominator and partial-coverage display
  before implementing each metric; update its scenario with a concrete numerical example.
- [Calendar windows drift] -> Test agreed boundaries, short histories, leap dates and zone changes.
- [Charts hide meaning at large text or with VoiceOver] -> Provide equivalent accessible detail and
  validate the chosen interaction on the device.

## Slice decisions

Metrics, calendar versus rolling ranges, bucket granularity and chart interactions are intentionally
left for the corresponding slices. These decisions may revise specs and task details; they do not
permit silently dropping week, month, six-month or year support from M1.
