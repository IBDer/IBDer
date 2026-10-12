# ADR-0005: OpenSpec as the single source of truth, two human gates

- **Status**: Accepted
- **Date**: 2026-10-11

## Decision

- `openspec/` is the sole authority on "what the system is like now"; GitHub Issues serve only as a kanban.
- Any implementation must first pass **gate 1 (human spec review)**; any merge must first pass **gate 2 (human code review)**.
- One change, one branch, one PR, one tag.

## Rejected options

- **GitHub Issues carrying the spec**: the overall picture of the system would be scattered across closed issues.
- **Running both in parallel**: drift is inevitable, and the next agent will read whichever one suits it.
- **Pushing straight to main**: it conflicts with "every change gets a human review".

## Consequences

- Every change has a spec carrier that can be diffed and reviewed.
- After archiving, the delta spec is merged into the main spec, and the history remains traceable.
