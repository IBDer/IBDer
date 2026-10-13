# Process: OpenSpec and the two human gates

**Status: draft, pending review.**

## Single source of truth

- **What the system is like now** → `openspec/specs/`
- **What is being changed** → `openspec/changes/<change-name>/`
- **Why it was decided this way** → `docs/adr/`
- GitHub Issues only serve as a board for "who is doing which item right now"; they **do not carry spec**.

## Lifecycle of a change

```
1. Think it through   grilling / explore (no code, no spec)
2. Write the change   openspec propose → proposal + delta spec + tasks
3. [Gate 1]           The maintainer reads a plain-language summary, plus a reference image where the change is visual
4. Implement          TDD; one change one branch change/<name>
5. Open a PR          screenshots or a demo + a one-line statement of what changed
6. [Gate 2]           The maintainer looks at the running product, never at the code
7. Merge              performed by a human
8. Archive            archive → delta merged into the main spec; tag
```

**Implementation must not start before gate 1 is passed.** This is the rule most easily broken in this repository, and the one with the highest rework cost.

What the maintainer is asked to judge — and what machines prove instead — is in
[review-gates.md](review-gates.md).

## Gate 1 review checklist

- [ ] States the Patient problem to be solved, and where the evidence comes from
- [ ] States the non-goals (what this **does not** do)
- [ ] Every acceptance criterion can be tested or manually verified
- [ ] Privacy impact: where the data comes from, where it is stored, whether it leaves the device
- [ ] Boundary impact: whether the output is "facts the Patient recorded" or "a conclusion the product reached". Scoring output has been decided by [ADR-0009](../adr/0009-no-scores-in-v1.md) to be **not built in the first version**; anything involving causation, diagnosis or treatment advice, or community UGC must have an explicit decision first
- [ ] Whether new terminology is needed; if so, update CONTEXT.md first

## Gate 2 review checklist

- [ ] Consistent with the spec; if there is a deviation, the spec is updated first
- [ ] Tests cover the acceptance criteria in the spec
- [ ] No hard-coded copy, colors, or font sizes
- [ ] No health content enters logs
- [ ] Behavior under large text / VoiceOver / Reduce Motion meets the specification
- [ ] Nothing beyond the spec was done along the way

## Branches, commits, and tags

- Branches: `change/<change-name>`; for documentation: `docs/<topic>`.
- Commit messages: **English**, imperative subject line stating what was done (ADR-0011); agent-assisted work ends with the co-author trailer (AGENTS.md §7).
- agents **do not merge on their own** and **do not tag on their own**.
- After archiving, a human applies the tag (`v0.x.0`).
