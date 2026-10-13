# Process: who reviews what, and how

**Status: draft, pending review.**

The maintainer does not write or read Swift. This repository is built by agents, so the review model is
built around what a human can actually judge: **the running product**. Everything else is proven by
machines, or not claimed at all.

## The two human gates

| Gate | When | What the maintainer sees | What they answer |
| --- | --- | --- | --- |
| **Gate 1 — requirements** | before code | a plain-language summary of what will exist and what will not, plus a reference image where the change is visual | yes / no / change this |
| **Gate 2 — the product** | after code | screenshots, or a short screen recording, of the running app, plus one line on what changed | yes / no / change this |

**A gate is never a code review.** The maintainer is not asked to read Swift, diffs, or long documents.
If a slice cannot be shown as a screenshot or a demo, it does not get its own gate — see the batching
rule below.

## What machines prove instead

| Concern | Proven by |
| --- | --- |
| It compiles and the tests pass | CI on a macOS runner (`.github/workflows/ci.yml`) |
| The style rules hold | SwiftLint / SwiftFormat in CI |
| The change matches the spec | the two-axis review (`code-review`) that the agent runs **before** asking for review; the outcome is reported in one line |
| No health content in logs, no score on screen | the self-check list in the PR template, checked by the agent |

A slice with **no visible surface** — domain model, persistence, CI, a refactor — is verified by tests
alone. The agent reports it in **one line** ("the event envelope is in, 23 tests, CI green") and does not
ask for a review. Only slices with something to look at interrupt the maintainer.

## Rules for agents

1. **Every UI slice ends with screenshots.** Store them under
   `docs/design/review/<date>-<slice>/` with a short README, and say in the PR which states they show.
2. **Ask concrete questions.** Three or four, not "please review". Bad: "review the Today screen".
   Good: "can you tell in one second what today contains?"
3. **Write PR descriptions for a non-programmer**: at most three short sections — what changed, what to
   look at, what is deliberately not in it. No file lists, no test names, no diff summaries.
4. **Never ask the maintainer to read code.** If a decision can only be explained by code, make the
   decision visible instead — a screenshot, or one sentence describing the difference in behaviour.
5. **Batch invisible work.** If a slice produces nothing to look at, it ships together with the next
   slice that does.

## What this costs

- **A visual-first order.** Screens come before the data layer beneath them, fed by synthetic data that
  is clearly marked. Expect rework when the real model lands; that is the accepted price of reviewing
  what actually matters.
- **Screenshots go stale.** They are review artifacts, not product assets. They are replaced when the
  screen changes, never maintained.
- **The agent carries more of the correctness burden**, because a human no longer checks it. That is why
  CI and the tests are mandatory rather than advisory.
