# Tasks: biologic scheduling (M1)

Moved from the original recording bundle; none of these behaviors is implemented. Product details are
settled in the named slice and reflected in its scenarios before production code is written.

## 1. Kinds and pending arrangements (issue #17)

- [ ] 1.1 Agree kind entry, required arrangement fields and single/recurring appointment scope — verify the choices and acceptance examples are captured in this change.
- [ ] 1.2 Implement separate arrangement, appointment and actual-dose domain values with kind/history — verify a kind change preserves historical doses and future appointments never count as received doses.
- [ ] 1.3 Add persistence mapping — verify linked entities and prior arrangements survive store reopen.
- [ ] 1.4 Build kind/arrangement entry and appointment review — verify stored patient-entered values appear without a suggested regimen, dose or interval.
- [ ] 1.5 Implement reschedule, cancel, postpone and skip behavior — verify prior dates remain in history and no pending-item transition creates a fact.

## 2. Local reminders (issue #19)

- [ ] 2.1 Agree reminder timing, actions and permission interaction — verify concrete allowed/denied and ignored-notification scenarios are recorded.
- [ ] 2.2 Implement scheduling and reconciliation — verify one intended notification per item, replacement after reschedule, removal after cancel/complete and no duplicates on relaunch.
- [ ] 2.3 Show notification denial/scheduling failure without losing the appointment — verify both states using a test scheduler and device permission checks.
- [ ] 2.4 Connect notification actions — verify dismissal alone saves no dose and any confirmation route requires the patient's explicit actual-dose statement.

## 3. Actual infusion facts (issue #18)

- [ ] 3.1 Agree minimum actual-dose fields, backfill and appointment-link interaction — verify the revised scenarios describe both linked and standalone recording.
- [ ] 3.2 Build the actual infusion flow and after-the-fact notes — verify changed dates persist, existing links are retained, the appointment is completed only after explicit recording, and repeated confirmation does not duplicate a dose.
- [ ] 3.3 Verify device integration — rehearse appointment creation, reminder availability, reschedule, cancellation, explicit completion and large-text review with synthetic data and captures.

## Workflow follow-up

- Verify the recording/storage dependency rather than assuming merged placeholders satisfy it.
- Sync only implemented schedule behavior and archive after capability review, not merely after planning.
