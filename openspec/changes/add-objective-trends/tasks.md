# Tasks: objective trends (M1)

This new capability implements no chart yet. Refine each metric and visual interaction during its
slice; all four ranges remain part of M1. Use synthetic source records for every shared example.

## 1. First useful metric

- [ ] 1.1 Agree the initial metric, unit, counting rule, denominator and missing-data display — verify a concrete numerical example and expected source facts appear in the spec.
- [ ] 1.2 Agree calendar/rolling boundaries, browsing and buckets for each range — verify dated examples cover week, month, six months and year.
- [ ] 1.3 Implement pure date windows and aggregation — verify boundary inclusions, sparse histories, leap dates, agreed time-zone behavior and the selected metric's numerical example.
- [ ] 1.4 Build a first interactive metric slice using stored facts — verify its displayed figure and source detail agree and obtain feedback on the running chart.

## 2. Complete range and metric coverage

- [ ] 2.1 Add the remaining agreed metrics with definitions — verify each formula and denominator against source fixtures; pending appointments never contribute actual-dose counts.
- [ ] 2.2 Implement every range and historical browsing — verify all four work with no records, three days of records and a synthetic year-long history.
- [ ] 2.3 Preserve coverage and respond to corrections — verify missing is not explicit zero, partial event history is not full-day coverage, and cross-period edits/deletions update chart and detail consistently.
- [ ] 2.4 Verify usable accessible detail — demonstrate bucket inspection, largest text and VoiceOver equivalents in the chosen design, with review captures.

## 3. Trend acceptance

- [ ] 3.1 Exercise recording-to-trend integration — save, relaunch, backfill, edit and delete synthetic daily and actual biologic records, then verify agreed statistics in each range without daily confirmation or a disease conclusion.

## Workflow follow-up

- Record accepted visual/calculation changes in this change as implementation evolves.
- Verify and sync this capability independently; calendar time elapsed is not a prerequisite to testing a year range.
