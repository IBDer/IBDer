# Proposal: biologic kinds, appointments and reminders

## Why

The maintainer needs to manage biologic kinds, upcoming appointments and reminders in the M1 personal
MVP. These must remain distinguishable from doses actually received.

## What Changes

- Move the unimplemented biologic-schedule requirements from the original recording bundle here.
- Capture the biologic kind and existing care arrangement, manage appointment changes and history,
  and schedule device-local reminders that follow the appointment lifecycle.
- Preserve basic actual-infusion recording and links to appointments when present.
- Discuss kind entry, recurrence, lead times and notification actions during their respective slices;
  these details are not frozen by this outline.

## Capabilities

### New Capabilities

- `biologic-schedule`: biologic kinds, care arrangements, pending appointments, actual doses and reminders.

### Modified Capabilities

None; this capability has no main spec yet.

## Impact

Adds a feature, domain entities, storage mapping and local notification integration. Reuses recording
and persistence infrastructure as it becomes available. This is an M1 capability under
[the delivery plan](../../../docs/process/delivery-plan.md), with independently verifiable tasks.
