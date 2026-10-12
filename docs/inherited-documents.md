# Inherited documents: sources and verification status

Before this project started, a batch of documents already existed in the organisation. They were committed by the account `Zachary-wW` between 2026-10-08 and 10-10, but **have not yet been verified one by one by a human**.

**Rule: a document whose status is not "verified" can only be a lead, never a basis.** (see section 1 of [AGENTS.md](../AGENTS.md))

**The authority order has been unified (2026-10-12)**: previously the App repository's `AGENTS.md` and `project-context/AGENTS.md` each had their own order. Now section 1 of [AGENTS.md](../AGENTS.md) is the single authority order, and the `project-context` side references this table instead.

## Inventory

| Document | Repository | Introducing commit | Date | Status | Where it is used now |
| --- | --- | --- | --- | --- | --- |
| `SAFETY.md` | IBDer/.github | 92907297 | 10-09 | **Not verified** | One of the sources for section 3 of AGENTS.md. **Cross-check correction**: that section lists 5 items, of which "Patient community UGC" and "clinical scale names/wording/images/translations" actually come from `project-direction.md`, while SAFETY.md's "medication adjustment advice" and "efficacy or safety conclusions not supported by appropriate evidence" did not enter that section |
| `AI_COLLABORATION.md` | IBDer/.github | 92907297 | 10-09 | **Not verified** | AI disclosure in section 9 of AGENTS.md |
| `PRIVACY.md` | IBDer/.github | 92907297 | 10-09 | **Not verified** | Synthetic test data only |
| `GOVERNANCE.md` `ROADMAP.md` `CONTRIBUTING.md` `RESEARCH_POLICY.md` | IBDer/.github | 9ada592f / 92907297 | 10-08/09 | **Not verified** | Not used |
| `decisions/project-direction.md` | project-context (private) | 48637080 | 10-08 | **Not verified** | The first version treated it as an established constraint; it is now downgraded to a lead |
| `decisions/community-direction.md` | project-context (private) | — | 10-09 | **Not verified** | Not used |
| `decisions/brand-direction.md` | project-context (private) | — | 10-08 | **Partially superseded** | Brand visuals now follow the logo/banner actually in use ([ADR-0010](../adr/0010-brand-source-of-truth.md)); **the logo prohibition list and tone words are still in effect** |
| `product/rebuild-brief.md` | project-context (private) | 48637080 | 10-08 | **Not verified** | "Define the problem and the specification first, then choose the tech stack" |
| `product/legacy-domain-language.md` | project-context (private) | 48637080 | 10-08 | **Not verified** | **The entire source of the CONTEXT.md glossary** |
| `product/legacy-product-learnings.md` | project-context (private) | — | 10-08 | **Not verified** | The list of "decisions not inherited" |
| `research/` (private, 5 long documents) | project-context (private) | — | 10-08/09 | **Not verified** | Background input on the domain and compliance |
| `research/` (public) | IBDer/research | 3 commits | 10-08/09 | **Not verified** | Not used |

> Commit identity note: `Zachary-wW <zhihaowei1117@gmail.com>` is a local git client; `Zachary WEI <124166324+Zachary-wW@users.noreply.github.com>` is the GitHub web editor or API writes. **git cannot distinguish "written by a human" from "written by an agent on their behalf"**, so this table records facts only and does not judge authorship.
>
> **Verifiable review records: none.** `IBDer/.github` has 11 commits, 0 PRs and 0 Issues, all committed directly to main; `IBDer/project-context` has 3 commits and 0 PRs. In other words, this batch of documents **left no trace of any human review** — "verified by a human" can neither be proven nor disproven in git.

## How verification works

For each document, the human maintainer gives one of three conclusions:

- **Verify**: the content is acceptable and can be used as a basis (the status column becomes "Verified + date").
- **Revise**: point out what needs changing, then verify after the changes.
- **Discard**: it is not used as a basis; repository content that depends on it is deleted or rewritten accordingly.

## Dependencies (things not to touch before the verification results are in)

| If this one is discarded or rewritten | What must be changed along with it |
| --- | --- |
| The four red lines in `SAFETY.md` | It has been decided to **not preset** them, per [ADR-0008](adr/0008-no-standing-red-lines.md); reference them later when each one is decided |
| `legacy-domain-language.md` | All terminology in [CONTEXT.md](../CONTEXT.md), and the suffix table and prohibited words in [naming.md](engineering/naming.md) |
| `brand-direction.md` | The color direction in [design-tokens.md](design/design-tokens.md) |
| The Planning standard in `rebuild-brief.md` | Gate 1 in [workflow.md](process/workflow.md) |
