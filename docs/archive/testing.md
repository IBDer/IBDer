# Process: Testing

**Status: draft, pending review.**

## Where TDD applies

**Tests must be written first** (these are the places where mistakes cost the most, and there is no intuitive feedback):

- Counting definitions: counts, groupings, time windows, denominators
- RecordCompleteness rules: missing ≠ 0; a partial record must not be treated as complete
- The rules for converting and not converting PlanIntent / PendingTask / Fact
- Date and time zone boundaries (calendar-day window, crossing midnight, daylight saving time)
- Export and restore: version validation, integrity validation, failure does not damage existing data

**Tests may be written later**: display-only views, copy, one-off scripts.

**Cover with UI tests**: only a few critical paths (cold start → record one ToiletEvent → go back and see it).

## Three layers

| Layer | Scope | Speed | When it runs |
| --- | --- | --- | --- |
| Unit | Domain (pure logic) | Milliseconds | Every save |
| Integration | Data (in-memory persistence) | Seconds | Every commit / CI |
| UI | Critical paths | Minutes | CI / before merge |

## Test data

- **Synthetic data only.** Real Patient records must not be used, including screenshots, fixtures, and logs.
- Synthetic data must cover the boundaries: crossing midnight, empty months, skipping whole days, recording only part of it, edited events.

## Relationship to the spec

- Every acceptance criterion in the spec must point to at least one test or one manual verification step.
- Acceptance criteria that cannot be tested must be rewritten until they are verifiable — this is the responsibility of gate 1.

## Prohibited

- Deleting or skipping tests to get green (`skip` requires the reason and a plan to add the test to be stated in the PR).
- Using real names, real hospitals, or real drug doses as fixture content.
