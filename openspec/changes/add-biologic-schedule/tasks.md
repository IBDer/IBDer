# Tasks: biologic scheduling (M1)

Moved from the original recording bundle; none of these behaviors is implemented. Product details are
settled in the named slice and reflected in its scenarios before production code is written.

## 1. Kinds and pending arrangements (issue #17)

- [x] 1.1 Agree kind entry, required arrangement fields and single/recurring appointment scope — settled 2026-10-20: six-product catalogue with label regimens, a plan as a sequence of dated doses, optional weight calculation, recorded amount. See design.md "Slice decisions".
- [x] 1.2 Implement separate arrangement, appointment and actual-dose domain values with kind/history — verify a kind change preserves historical doses and future appointments never count as received doses.
- [x] 1.3 Add persistence mapping — an archive of plan, doses and records round-trips through a reopened file (BiologicScheduleTests).
- [x] 1.4 Build kind/arrangement entry and appointment review — verify stored patient-entered values appear without a suggested regimen, dose or interval.
- [ ] 1.5 Implement reschedule, cancel, postpone and skip behavior — verify prior dates remain in history and no pending-item transition creates a fact.

## 2. Local reminders (issue #19)

- [x] 2.1 Agree reminder timing, actions and permission interaction — settled 2026-10-20: two weeks, one week and one day before, each switchable; overdue shown in the alert colour.
- [ ] 2.2 Implement scheduling and reconciliation — verify one intended notification per item, replacement after reschedule, removal after cancel/complete and no duplicates on relaunch.
- [ ] 2.3 Show notification denial/scheduling failure without losing the appointment — verify both states using a test scheduler and device permission checks.
- [ ] 2.4 Connect notification actions — verify dismissal alone saves no dose and any confirmation route requires the patient's explicit actual-dose statement.

## 3. Actual infusion facts (issue #18)

- [ ] 3.1 Agree minimum actual-dose fields, backfill and appointment-link interaction — verify the revised scenarios describe both linked and standalone recording.
- [x] 3.2 Build the actual infusion flow and after-the-fact notes — verify changed dates persist, existing links are retained, the appointment is completed only after explicit recording, and repeated confirmation does not duplicate a dose.
- [ ] 3.3 Verify device integration — rehearse appointment creation, reminder availability, reschedule, cancellation, explicit completion and large-text review with synthetic data and captures.
- [ ] 3.4 Build postponement and a changed rule — verify one appointment moves with a reason, and an interval change starts from a stated dose with its reason kept.
- [ ] 3.5 Build the pre-infusion checklist — verify items can be ticked and outstanding items never block completion.

## Workflow follow-up

- Verify the recording/storage dependency rather than assuming merged placeholders satisfy it.
- Sync only implemented schedule behavior and archive after capability review, not merely after planning.
