# Proposal: visit summary and export follow-up

## Why

A later external-testing milestone needs a period summary that can be reviewed and shared with a
clinician. Keeping this separate lets M1 personal recording, reminders and trends finish independently.

## What Changes

- Move the existing unimplemented visit-summary requirements into their own change.
- Preserve deterministic summary generation, visible completeness, traceability and explicit sharing.
- Retain both human-readable and versioned structured export as planned M2 work.

## Capabilities

### New Capabilities

- `visit-summary`: a factual period summary and its two export forms.

### Modified Capabilities

None; no summary capability has shipped.

## Impact

A later feature will read recorded facts and completeness without modifying them. Export format and
presentation decisions are discussed before their slices. This move implements no summary or backup.
See [the delivery plan](../../../docs/process/delivery-plan.md).
