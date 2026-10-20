# Proposal: objective trends across four time ranges

## Why

The M1 personal MVP needs useful history across a week, month, six months and year, rather than only
individual days. The maintainer references Apple Fitness for browsing and time navigation, with exact
metrics and interface details to be refined during implementation.

## What Changes

- Add all four range choices and browsing of recorded history from the first usable version.
- Derive agreed statistics from actual records with visible data coverage and traceable detail.
- Recompute after edits and deletions, and exercise long ranges with synthetic fixtures.
- Discuss each metric, its units, denominator, date boundaries and chart interaction before its slice.
- Work with partial histories without requiring the future daily-confirmation screen.

## Capabilities

### New Capabilities

- `objective-trends`: factual historical statistics, time-range navigation and data coverage.

### Modified Capabilities

None; there is no existing trend implementation or main spec.

## Impact

Adds a trend feature and pure aggregation/date-window logic using stored records. Chart selection and
aggregation granularity remain slice decisions, not implied requirements. Existing ADR-0009 applies.
M1 scope and device acceptance are in [the delivery plan](../../../docs/process/delivery-plan.md).
