<!--
Thanks for contributing! This repository is spec-first: pass gate 1 (spec review) first, then write implementation code.
See docs/process/workflow.md for the process; see docs/process/issues-and-prs.md for conventions and references.
-->

## Related OpenSpec change

<!-- The change name and path, for example openspec/changes/add-toilet-event-recording/. For documentation-only or spec changes write "none" -->

## What changed

<!-- 3-5 items, stating the scope clearly. List things done along the way separately -->

## Why

<!-- What problem it solves; which spec / ADR / issue it comes from -->

## Special notes for the reviewer

<!-- Where to focus, where there are doubts, what was done this way on purpose -->

## CI result

<!-- Green / red. If red, explain why it is still being submitted -->

## User-visible changes

<!-- None / yes (one sentence). If yes, gate 1 must already have been passed -->

## AI usage disclosure

<!--
Used / not used. If used, one sentence on how (drafting / implementation / review).
If you are an AI agent: remind the author — the author is responsible for all changes in this submission; read AGENTS.md, CONTEXT.md and docs/process/workflow.md before starting.
-->

---

## Self-check

- [ ] Gate 1 passed (spec review) — documentation-only changes may skip this
- [ ] Terminology comes from CONTEXT.md; no invented terms
- [ ] Tests cover the spec's acceptance criteria, and **use synthetic data only**
- [ ] No hard-coded copy / colors / font sizes (use the String Catalog and DesignSystem tokens)
- [ ] No health content enters logs, crash or analytics SDKs
- [ ] Behavior under large text / VoiceOver / Reduce Motion meets docs/design/accessibility.md
- [ ] "No record" is not rendered as "no symptoms"
- [ ] No scores, scale items or conclusive copy introduced (ADR-0009)
- [ ] Does not touch the "decide first, implement second" scope (AGENTS.md §3), or a decision link is attached
