# Agent working agreement

Every agent working in this repository starts here. Read it before doing anything.

## 1. Authority order

Lower number wins:

1. The user's current instruction
2. Public rules in [IBDer/.github](https://github.com/IBDer/.github) and [IBDer/research](https://github.com/IBDer/research) that **a human has verified**
3. Accepted ADRs in `docs/adr/` and the current spec in `openspec/specs/`
4. Confirmed decisions in [project-context](https://github.com/IBDer/project-context)
5. Re-verified primary sources (guidelines, regulators, platform policy)
6. Unverified drafts, historical material, private research

**Unverified = lead only.** Status lives in [docs/inherited-documents.md](docs/inherited-documents.md).

## 2. Where things live

| The question | The file |
| --- | --- |
| How do I work here? | this file |
| What does this word mean? | [CONTEXT.md](CONTEXT.md) |
| Why was this decided? | [docs/adr/](docs/adr/) |
| What does the system do? | [openspec/specs/](openspec/specs/) |
| Who reviews what? | [docs/process/review-gates.md](docs/process/review-gates.md) |
| Can I trust this old document? | [docs/inherited-documents.md](docs/inherited-documents.md) |
| What is waiting on me? | the [needs-decision issues](https://github.com/IBDer/IBDer/issues?q=is%3Aissue+is%3Aopen+label%3Aneeds-decision) |
| Where are we right now? | `scripts/handoff.sh` — generated, never stale |

Anything else that looks like a rule is history: the five places above are the whole of it.

**One entry point.** Never add `CLAUDE.md`, `.cursorrules` or a tool-specific copy — every tool reads this file, and copies only drift. A rule belongs here only if **every session needs it**; otherwise it becomes a skill (loaded when its description matches) or a document (read when relevant).

## 3. Code layout

```
IBDer/
  App/            assembly, navigation, dependency injection
  Features/       one folder per capability, plural names
  Domain/         entities, rules, use cases — imports neither SwiftUI nor SwiftData
  Data/           persistence, export
  DesignSystem/   Tokens/ and Components/
IBDerTests/
```

Dependencies point downwards only.

## 4. Decide first, implement second

This repository presets no medical red lines (ADR-0008). The maintainer decides these **before**
implementation: diagnosis / treatment advice / telemedicine / triage; disease-activity scores and
verdicts such as "remission / active / flare"; food-to-symptom causation; patient-community UGC;
clinical scale names, wording, images, translations.

The test: **is the output a fact the patient recorded, or a conclusion the product reached?**

## 5. Data and privacy

- **Synthetic data only.** Never real or identifiable patient data — not in the repository, issues, logs, screenshots, or any third-party AI service.
- No health content in crash or analytics SDKs.
- No dependency that moves health data off the device without a decision.

## 6. Sourcing

- Never copy text from the private research repository. Re-verify, rewrite, state the uncertainty.
- Distinguish fact / interpretation / hypothesis / decision.
- For rules and policy: official sources only, with region, validity, and verification date.

## 7. Language

English everywhere — docs, ADRs, specs, identifiers, comments, commit messages, PRs, issues, branch
names (ADR-0011). The single exception is the `zh-Hans` product strings in the String Catalog.

## 8. Work

- **Issue first**: every slice starts as a GitHub Issue; the PR body says `Closes #N`.
- **Spec first**: `openspec/changes/<name>/`, then [gate 1](docs/process/review-gates.md), then code.
- Branches: `change/<name>`, `impl/<name>`, `docs/<topic>`.
- **Test first where the risk is real**: counting, completeness, date windows, plan/fact boundaries, export and restore.
- Style is enforced by tools, not by memory: `swiftformat --lint . && swiftlint --strict`.
- Design work follows the `ibder-design` skill; every UI change follows `visual-acceptance`.
- Commit messages end with:
  `Co-authored-by: ConceptWei <60024976+ConceptWei@users.noreply.github.com>`

## 9. Review

- **Write every PR for someone who does not read code**: what changed, what to look at, what is deliberately not in it — plus screenshots for anything visible.
- **Never ask the maintainer to read code or a long document.** If a decision can only be shown in code, make it visible in behaviour instead.
- Humans merge and tag; agents do not.
- Never commit on a red CI.

## 10. What the maintainer decides

Four things, and only four: **how it looks and behaves**; **what we say publicly**; **money and law**
(accounts, filing, licensing); **anything inside §4**. Everything else the agent decides and records as
an ADR.

## 11. AI disclosure

Material drafted by AI is traceable and stated in the PR. The human maintainer is accountable.
