# Proposal: a profile the app can trust, filled in once

## Why

M1 needs the patient's own numbers — height, weight, diagnosis, current treatment and known
complications — so the biologic plan can start from a real weight and the settings screen can show
something true. Today the app knows nothing about the person using it.

## What Changes

- Add a profile entered on first launch and editable later from the settings tab.
- Ask three short pages: the body, the disease, the treatment. Every page can be skipped.
- Record the doctor's stated disease state; never compute one.
- Keep the profile on the device with the records, in its own file.

## Capabilities

### New Capabilities

- `patient-profile`: what the app knows about the patient, how it is entered, and how it is reused.

### Modified Capabilities

None; weight-based dose calculation belongs to `biologic-schedule`, which reads this profile.

## Impact

Adds a domain value, a second small store, an onboarding flow and a settings surface. The recording,
biologic and trends screens may read the profile but never write it. This is M1 work under
[the delivery plan](../../../docs/process/delivery-plan.md).
