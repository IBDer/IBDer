# Agent working agreement

Every AI agent working in this repository starts here. **Read this file before doing anything.**

## 1. Authority order (the only one)

When two sources conflict, the lower number wins:

1. The user's current instruction
2. Public rules in [IBDer/.github](https://github.com/IBDer/.github) and [IBDer/research](https://github.com/IBDer/research) that **a human has verified**
3. Accepted ADRs in `docs/adr/` and the current spec in `openspec/specs/`
4. Decisions in [project-context](https://github.com/IBDer/project-context) that **the maintainer has confirmed**
5. Re-verified primary sources (clinical guidelines, regulators, platform policy)
6. Unverified drafts, historical material, private research

> **This table is the only authority order.** `project-context/AGENTS.md` refers to it instead of defining its own (unified 2026-10-12).
>
> **Unverified = lead only.** Check the status column in [docs/inherited-documents.md](docs/inherited-documents.md). A document that is not verified may not be used as a basis for implementation, and may not be cited as "already decided".

## 2. Reading order

1. This file
2. [CONTEXT.md](CONTEXT.md) — identifiers come from here
3. [docs/process/workflow.md](docs/process/workflow.md) — how a change moves
4. The `docs/` files and `openspec/specs/` relevant to the task

## 3. Medical boundary: decide first, implement second

**This repository does not preset medical red lines** (see [ADR-0008](docs/adr/0008-no-standing-red-lines.md)). Constraints are decided per feature and recorded as their own ADR.

The following must be **explicitly decided by a human maintainer before implementation** — do not build first and ask later:

- diagnosis, individualised treatment advice, telemedicine, emergency triage
- disease-activity scores, and verdict-style output such as "remission / active / flare"
- causal claims linking food to symptoms
- patient-community UGC
- names, wording, images, or translations of clinical scales

One test settles it: **is the output a fact the patient recorded, or a conclusion the product reached?** Facts can be built. Conclusions get decided first.

## 4. Data and privacy

- **Synthetic data only.** Real or identifiable patient data must never enter the repository, issues, discussions, logs, screenshots, or any third-party AI service.
- The app must not report health content to crash or analytics SDKs.
- Do not add a dependency that sends health data off the device without an explicit decision.

## 5. Sourcing discipline

- Text from the private research repository must **not** be copied into this repository. Re-verify public sources, write it in your own words, and state the uncertainty.
- Distinguish **fact / interpretation / product hypothesis / project decision**. Never present the last three as the first.
- For regulation and policy, cite official sources only, and record region, validity period, and verification date.

## 6. Workflow (OpenSpec is the single source of truth)

```
grilling / explore      think it through
  -> openspec change    proposal + delta spec + tasks
      -> [GATE 1: human reviews the spec]      <- no implementation before this
          -> implement (TDD)
              -> PR with CI evidence
                  -> [GATE 2: human reviews the running product] -> merge -> archive
```

- **OpenSpec is the authority on what the system does.** GitHub Issues is a board; it does not carry spec.
- If an issue and a spec disagree, `openspec/` wins.
- A change that has not passed gate 1 must not be implemented.

## 7. Commits and review

- One change per branch: `change/<change-name>`. Implementing an already-merged change: `impl/<change-name>`. Docs-only work: `docs/<topic>`.
- **Write every PR for someone who does not read code**: at most three short sections — what changed, what to look at, what is deliberately not in it — plus **screenshots for anything visible**. See [docs/process/review-gates.md](docs/process/review-gates.md).
- **Never ask the maintainer to read code or a long document.** If a decision can only be shown in code, make it visible in behaviour instead.
- Never commit on top of a red CI.
- Humans merge; agents do not merge and do not tag.
- Tag each archived change.
- **Co-author trailer**: agent-assisted work ends its commit message with
  `Co-authored-by: ConceptWei <60024976+ConceptWei@users.noreply.github.com>`.
- **Commit messages, PR bodies, and issues are written in English** (ADR-0011).

## 8. Language

- **English everywhere**: documentation, ADRs, OpenSpec specs, code identifiers, code comments, commit messages, PRs, issues, branch names (ADR-0011).
- **Only exception**: user-facing product strings. The app ships `zh-Hans`; those live in the String Catalog, never in docs, comments, or code literals.
- Identifiers come from [CONTEXT.md](CONTEXT.md).
- New project content is never written in Chinese.

## 9. AI disclosure

When AI drafts anything material — a rule, a requirement, a design decision — that must be traceable and stated in the PR. Final responsibility rests with the human maintainer. Public content follows the organisation template.
