# Naming Conventions

**Status: draft, pending review.** Core rule: **domain nouns in code may only come from [CONTEXT.md](../../CONTEXT.md).**

## Why

When several agents develop in relays, the biggest hidden loss is **one concept given three names** (or one name meaning three things). The glossary turns this into a checkable rule.

## Rules

1. New domain concept → open a PR to change CONTEXT.md first → then write code.
2. Code identifiers are in English and must be the entry in the **identifier column** of the glossary (for example `ToiletEvent`, not `BowelMovement`).
3. Synonyms are forbidden: one concept allows exactly one identifier.
4. Type suffixes have fixed meanings:

| Suffix | Meaning |
| --- | --- |
| `Plan` | PlanIntent (future) |
| `Task` / `Appointment` | PendingTask |
| `Record` / `Event` | Fact (already happened) |
| `Confirmation` | the Patient's supplementary confirmation for a period of time |
| `Summary` | summary output, containing no conclusion |
| `Trend` | ObjectiveTrend display |

5. **Conclusive terms must not be invented.** The canonical list lives in [CONTEXT.md](../../CONTEXT.md) — disease activity, remission, flare, worsening, score, risk prediction — and the same restriction applies to their identifier forms (`diseaseActivity`, `remission`, `flare`, `severityScore`, `riskPrediction`). None of them may enter identifiers, UI copy, or comments before the relevant feature has its own decision (ADR).

## File Names and Directory Names

- The type name matches the file name: `ToiletEvent.swift`.
- Directory names use the plural to denote a collection: `Features/ToiletEvents/`.
