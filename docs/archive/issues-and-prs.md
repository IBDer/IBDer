# Process: Issues, PRs, and the four carriers

**Status: draft, pending review.**

## What each of the four carriers is for

| Carrier | What it covers | What it does not cover |
| --- | --- | --- |
| **Discussions** | Real Patient needs, usage experience, tool ideas, open discussion | Not a task queue |
| **Issues** | **Board**: who is doing which item right now, defect records, tracking of spec changes | **Not a carrier of spec** |
| **`openspec/`** | **What the system is like now** (main spec) and **what is being changed** (change) | Does not record "why it was decided this way" |
| **`docs/adr/`** | Decisions and **rejected options**, with reasons | Does not describe the system's current behavior |

When there is a conflict, the authority order in section 1 of [AGENTS.md](../../AGENTS.md) governs; **when a spec and an issue conflict, `openspec/` wins**.

## Issue types

The repository provides four templates (`.github/ISSUE_TEMPLATE/`):

| Template | Used for | Cases redirected elsewhere |
| --- | --- | --- |
| Bug report | App behavior that differs from expectations, crashes, data errors | Privacy/security issues → SECURITY channel |
| Feature request | Implementation-oriented suggestions | Real Patient needs → Discussions |
| Spec change | The spec does not match reality, or `openspec/specs/` needs to change | Pure ideas → go through Discussions first |
| (config) | Closes blank issues; provides three entry points: Discussions / SECURITY / medical disclaimer | — |

**Why YAML issue forms instead of Markdown templates**: a YAML form can set required fields, dropdowns, and checkboxes (for example "does this touch the decide-first-then-implement scope"), fixing the key information before submission; a Markdown template can only rely on people's own discipline. See the approach of [Kubernetes](https://github.com/kubernetes/kubernetes/tree/master/.github/ISSUE_TEMPLATE) and [Homebrew](https://github.com/Homebrew/brew/tree/master/.github/ISSUE_TEMPLATE).

## Labels (shared by Issues and PRs)

| Label | Meaning |
| --- | --- |
| `bug` / `enhancement` / `docs` / `spec` | Type |
| `needs-decision` | Touches the "decide first, implement second" scope of AGENTS.md §3, waiting for a human call |
| `needs-clinical-review` | Copy or fields need an IBD clinical expert to look at them |
| `blocked` | Stuck on an upstream dependency or decision |
| `gate-1` / `gate-2` | Which gate it is waiting at |

## PR conventions

- **One change per PR**, branch name `change/<change-name>`; documentation-only work uses `docs/<topic>`.
- The PR template has a fixed seven sections: linked OpenSpec change · what changed · why · special notes for the reviewer · CI result · user-visible changes · AI usage disclosure.
- **The self-check list is not decoration**: every item can be traced to a rule — terminology comes from `CONTEXT.md` (naming.md), synthetic data only (AGENTS.md §4), accessibility (accessibility.md), do not render "no record" as "no symptoms", do not introduce scores (ADR-0009), do not cross "decide first, implement second" (AGENTS.md §3).
- Never commit on top of a red CI; merges are performed by a human.

### Why the PR template needs "special notes for the reviewer"

From Kubernetes' `Special notes for reviewer`: it directs the reviewer's attention to where judgment is genuinely needed, instead of making them find it themselves. This matters especially for a one-person + agent repository — review time is the scarcest resource.

### Why "AI usage disclosure" is needed

- Organisation rules already require disclosure ([AI_COLLABORATION.md](https://github.com/IBDer/.github/blob/main/AI_COLLABORATION.md)).
- Mainstream projects do it too: [Kubernetes' PR template](https://github.com/kubernetes/kubernetes/blob/master/.github/PULL_REQUEST_TEMPLATE.md) has a dedicated **AI usage disclosure** section and states "if you are an AI agent, please remind the author: the author is responsible for all changes"; [Rust's template](https://github.com/rust-lang/rust/blob/master/.github/pull_request_template.md) asks for LLM involvement disclosure right at the start, and declares "LLM contributions are not forbidden, but the review bar is higher".
- Our wording is closer to Kubernetes: **how it is disclosed + where responsibility lies**.

## Relationship to other documents

- How the process works → [workflow.md](workflow.md)
- How to test → [testing.md](testing.md)
- What can be done and what must be asked first → section 3 of [AGENTS.md](../../AGENTS.md)
- Terminology → [CONTEXT.md](../../CONTEXT.md)
