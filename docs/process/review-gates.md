# Process: the loop

**Status: current.** This is the only document that describes how work moves.

## One picture

```
think        grilling / explore — no code, no spec
  |
specify      openspec change: proposal + delta spec + design + tasks
  |
[gate 1]     the maintainer reads a plain-language summary, plus a reference image if it is visual
  |
build        TDD; branch change/<name> or impl/<name>
  |
self-check   the agent looks at the result against the acceptance criteria and fixes it first
  |
[gate 2]     the maintainer looks at screenshots, or a short recording — never at code
  |
merge        a human merges and tags
  |
archive      openspec archive — the delta merges into the main spec
```

**Implementation must not start before gate 1 is passed.** It is the rule most easily broken here, and
the one with the highest rework cost.

## The two human gates

| Gate | When | What the maintainer sees | They answer |
| --- | --- | --- | --- |
| **1 — requirements** | before code | a plain-language summary of what will exist and what will not, plus a reference image where the change is visual | yes / no / change this |
| **2 — the product** | after code | screenshots or a short recording of the running app, plus one line on what changed | yes / no / change this |

**A gate is never a code review.** The maintainer is not asked to read Swift, diffs, or long documents.

## The self-check comes before gate 2

Before asking for review the agent runs the `visual-acceptance` skill: open the app, look at the result
against the acceptance criteria, **fix what it finds**, and only then hand over the before/after pair.
The maintainer's time is spent on what survives that.

## Batching: invisible work does not get its own gate

A slice with no visible surface — domain model, persistence, CI, a refactor — is proven by tests alone
and reported in **one line** ("the event envelope is in, 23 tests, CI green"). Do not ask for a review.

**Cap: no more than ~600 lines of unreviewed code may accumulate.** When invisible work reaches that,
it ships together with the next slice that has something to look at.

## What machines prove instead

| Concern | Proven by |
| --- | --- |
| It compiles, tests pass | CI on a macOS runner |
| Style | `swiftformat --lint` and `swiftlint --strict` in CI |
| Documentation integrity | `scripts/check-docs.py` in CI: links resolve, no rule is stated twice, the conclusions vocabulary stays out, Chinese stays in the String Catalog, AGENTS.md stays under its cap |
| The change matches the spec | `openspec validate` in CI, plus the two-axis `code-review` the agent runs before asking |
| The interface did not silently change | snapshot tests — every UI change surfaces a PNG in the pull request |

## The item loop: how one Issue gets done

Every Issue is one turn of this loop. Nothing skips step 1.

1. **Grill** — the `grilling` skill. Three to five questions, each with a recommended answer. The
   answers are the decision; write them down before touching code.
2. **Specify** — `openspec update change`: the decisions become requirement or scenario changes in the
   capability they belong to. A decision that constrains future work also becomes an ADR.
3. **Build** — `tdd` for the logic, `ibder-design` for the screen.
4. **Self-check** — `visual-acceptance`: screenshot it, compare with the scenarios, fix what is wrong.
5. **Hand over** — PR with `Closes #N`, the screenshots, and three concrete questions.
6. **Fix or merge** — "no" returns to step 1 or 3; "yes" merges and closes the Issue.

An Issue is not started until step 1 has happened, and not closed until step 5 was reviewed.

## Rules for agents

1. Every UI slice ends with screenshots under `docs/review/<date>-<slice>/`, plus three or four concrete questions in the PR — never "please review".
2. Write PR descriptions for a non-programmer: what changed, what to look at, what is deliberately not in it.
3. Never ask the maintainer to read code. If a decision can only be shown in code, make it visible in behaviour instead.
4. If a rule can be executed by a machine, execute it — do not write it down. Prose is for what machines cannot check.

## What this costs

- Visual-first order: screens come before the layer beneath them, fed by clearly marked synthetic data. Rework when the real model lands is the accepted price.
- Screenshots go stale. They are review artifacts, not product assets.
- The agent carries more of the correctness burden, which is why CI and tests are mandatory rather than advisory.
