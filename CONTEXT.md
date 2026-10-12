# Domain vocabulary

**Status: draft, pending human review.** Every term below was extracted from an unverified draft (see [docs/inherited-documents.md](docs/inherited-documents.md)); until the maintainer confirms it, this table is a **proposal**, not a decision.

**While it is pending it is still the working vocabulary**: code uses these identifiers, and changing one is a normal pull request against this file. That is what [naming.md](docs/engineering/naming.md) means by "identifiers come from here" — it does not require this table to be finished before code exists.

**Rule: code identifiers may only be taken from this table.** Add a new concept here before writing code that uses it. Synonyms are not allowed.

## Roles

| Identifier | Definition | Do not use |
| --- | --- | --- |
| `Patient` | A person diagnosed with CD or UC whose health experience this product records. Not necessarily the person operating the app. | user, sufferer |
| `FamilyMember` | A person authorised by the patient to view or co-manage the log. | caregiver, guardian |
| `PatientProfile` | The body of information about one patient. **Not the same thing as a login identity.** | account, profile page, medical record |

## Three kinds of information that must never impersonate each other

| Identifier | Definition |
| --- | --- |
| `PlanIntent` | A **future** arrangement the patient entered from an existing care plan. |
| `PendingTask` | One still-open task or appointment produced by a plan. |
| `Fact` | Something the patient confirms **actually happened**. Ticking a reminder must never create a fact. |

## Event types (peers — none is more important than another, see ADR-0001)

| Identifier | Definition | Do not use |
| --- | --- | --- |
| `Event` | Shared envelope: time it happened, time it was recorded, type, completeness, edit history. | entry, log item |
| `ToiletEvent` | A time-stamped record of a bowel-related episode: stool, blood or mucus only, urge without passing anything, or uncertain. **Does not automatically equal one bowel movement.** | bowel movement count, flare record |
| `MealRecord` | One meal or snack that happened. May include an oral nutritional supplement. | daily diet, nutrition analysis |
| `MedicationRecord` | Medication or self-injection that was actually taken, with actual time and dose. | prescription, adherence score |
| `BiologicPlan` | The biologic arrangement the patient entered from their care team's instructions. **In v1** (ADR-0001). | treatment recommendation |
| `InfusionAppointment` | One pending infusion produced by the plan; confirmable, reschedulable, cancellable. **In v1**. | infusion plan, infusion record |
| `InfusionRecord` | One infusion that actually happened. **In v1, as a basic function** — and never created by dismissing a reminder. | treatment recommendation |

## Daily review

| Identifier | Definition | Do not use |
| --- | --- | --- |
| `DailyConfirmation` | The patient's end-of-day confirmation for one local day: totals, worst symptoms, and how completely each event type was recorded. Never auto-computed. | daily score, disease-activity check |
| `RecordCompleteness` | Explicitly distinguishes "recorded every one", "totals right but not itemised", "approximate", "not recorded". **Missing data is never counted as zero.** | completeness score |
| `PersonalBaseline` | The patient's own usual bowel frequency in remission (or before onset), with source and update time. **Never replaced by a population threshold.** | normal range |

## Output

| Identifier | Definition | Do not use |
| --- | --- | --- |
| `ObjectiveTrend` | Counting, grouping, or showing change over time from raw records. **Infers no causality, activity, diagnosis, or treatment.** | health score, severity, risk prediction |
| `VisitSummary` | Facts from a chosen period, for the patient to review or share. | diagnostic report, AI analysis |

## Vocabulary discipline

- Conclusion words — disease activity, remission, flare, worsening, score, risk prediction — may not enter UI copy or identifiers before a feature that needs them has its own decision (AGENTS.md §3).
- "No record" is not "no symptom". Every statistic states its data completeness.
- Plans and facts are displayed separately; rescheduling never overwrites the original arrangement.
- Chinese appears only as the `zh-Hans` UI label in the String Catalog, never as an identifier.
