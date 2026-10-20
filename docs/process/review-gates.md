# Process: the iteration loop

**Status: current.** Scope lives in [delivery-plan.md](delivery-plan.md); this file owns the working
method adopted in [ADR-0014](../adr/0014-m1-dogfood-and-iterative-delivery.md).

## One slice at a time

1. **Orient.** Read the Issue, owning OpenSpec change and existing decisions. State the current slice
   and the observable behavior that will prove it works.
2. **Resolve what matters now.** Reuse answers already given. Ask targeted questions only when an
   unresolved choice changes this slice's behavior or data meaning. Use exploration or a disposable
   prototype to make a choice concrete; no fixed questionnaire is required for every Issue.
3. **Record and build.** Update the affected requirements, scenarios, design and tasks, then implement
   the agreed slice. Test meaningful risks first: dates, counting, completeness, persistence and the
   distinction between plans and facts. Other milestone screens need not be designed first.
4. **Inspect and refine.** For UI work, run `visual-acceptance`, compare the running result with the
   scenarios, and fix findings before handover. Feedback may revise any planning artifact; keep the
   implementation and acceptance checks aligned with the revised intent.
5. **Hand over.** Open a focused PR linked to its Issue and change. Explain the behavior in plain
   language, attach captures for visible work, and ask only decisions still needed. Internal work is
   reported with its verification results.
6. **Verify and close.** Humans merge. Check Issue acceptance before closing it. Verify and sync a
   capability when its requirements are implemented and reviewed; archive its change afterwards.

The maintainer owns behavior and appearance, public statements, money/law and AGENTS.md section 4.
Engineering choices within the agreed slice are the agent's responsibility. Existing authorization
needs no ceremonial second approval; changed intent must become explicit before production changes.

## Keep changes small

One OpenSpec change owns one independently verifiable capability. It can span several implementation
PRs; each names its slice and remaining tasks. Learning about the same intent updates that change;
independently shippable intent gets a separate change.

Invisible work is supported by tests and reported briefly. Keep the existing cap of roughly 600 lines
of unreviewed implementation code, landing it with a visible slice when that helps product review.

## Evidence and its limits

| Check | What it establishes |
| --- | --- |
| Documentation script | Mechanical integrity, not agreement between product decisions. |
| OpenSpec strict validation | Artifact structure and schema validity, not feature completion. |
| SwiftFormat and SwiftLint | Style consistency. |
| Build and behavior tests | Compilation and the scenarios those tests actually exercise. |
| Snapshot comparisons | Visual changes on the configured runtime; skipped snapshots provide no comparison. |
| Review against scenarios | Coverage, correctness and agreement between artifacts and behavior. |
| Maintainer device trial | Whether the agreed flows are useful in daily use. |

Run a code review against the originating Issue/spec before handover. Each completed task needs
verification evidence. Record skipped or unavailable checks honestly and use synthetic data in all
shared evidence.

## Visible handover

Store captures under `docs/review/<date>-<slice>/`. Show the empty, populated and changed/error states
relevant to the slice; check large text and accessibility using `ibder-design`. Ask concrete product
questions when choices remain. A process-only PR needs neither fake screenshots nor questions whose
answers are already known.
