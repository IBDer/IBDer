# Proposal: daily confirmation follow-up

## Why

The original v1 plan included a patient-confirmed daily total, symptom selections and completeness.
This remains a follow-up hypothesis for M2 rather than a dependency that delays M1 recording or trends.

## What Changes

- Move the unimplemented daily-confirmation and fixed-symptom requirements out of the recording bundle.
- Preserve the distinction between event counts and patient-confirmed totals, including explicit zero.
- Revisit necessity, scale shape and interaction before implementation; existing drafts are not UI approval.

## Capabilities

### New Capabilities

- `daily-confirmation`: explicit daily totals, fixed symptom selections and per-type completeness.

### Modified Capabilities

None. The capability consumes daily records without changing their original facts.

## Impact

A future feature reads daily events and stores the patient's independent confirmation. M1 statistics
must work without it. Clinical wording review and the decision tracked in issue #16 still apply.
See [the delivery plan](../../../docs/process/delivery-plan.md) for milestone placement.
