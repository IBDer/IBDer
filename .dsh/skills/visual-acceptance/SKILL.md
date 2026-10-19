---
name: visual-acceptance
description: >
  Check a UI change against its acceptance criteria before asking anyone to review it. Use after any
  change that alters what a screen looks like or how it behaves: build it, run it, screenshot it,
  compare it with the criteria and with the previous state, fix what is wrong, and keep the pair as
  evidence. Also use when asked to "show me the change", "take a screenshot", or before opening a UI
  pull request.
---

# Visual acceptance

Nobody reads the diff. The screenshot *is* the review. So the screenshot has to be taken, looked at,
and acted on **before** it is handed over.

## The four steps

1. **Build and open it.** `xcode_run action=run` against a simulator, then `ios_sim_screenshot`.
2. **Compare with the acceptance criteria** — not with your intention. Read the spec's `#### Scenario:`
   blocks and check each one on screen.
3. **Fix what is wrong.** Never hand over a screenshot you already know is wrong. This step is the
   whole point: without it the maintainer becomes your debugger.
4. **Keep the pair.** Before and after, same viewport, under `docs/review/<date>-<slice>/`.

## What to capture

| Change | Capture |
| --- | --- |
| Anything visual | before and after at the **same** viewport |
| A flow | a 10–30 second recording, or one screenshot per step |
| Conditional UI | **one screenshot per state** — empty, partial, error. Reviewers never click through these by hand |
| Large text, dark mode, Reduce Motion | one screenshot each when layout or motion is touched |

Crop to what changed — a full capture of a 3000-point screen helps nobody. One caption line per image.

## Never capture

- Real or identifiable health information (AGENTS.md §4). The app runs on synthetic sample data; keep it that way.
- Secrets, tokens, account identifiers. A capture ends up in a pull request that stays visible.

## Reading the result against the criteria

The spec's scenarios are the checklist. For each: can you see the described behaviour on screen? If a
scenario cannot be checked visually, say so in the pull request instead of implying it was verified.

Then the four things this product is judged on:

- Can a tired person tell what today contains, and where to record the next thing?
- Do the four event types read as equal in weight (ADR-0001)?
- Is anything too small, too grey, or too cramped to use while unwell?
- Is there a score, a verdict, or a causal claim anywhere? There must not be (ADR-0009).

## Handing over

Put the images in the pull request **body**, not a comment — the body is what GitHub shows first. Say
which states are shown and which are not, and ask three or four concrete questions.

## When there is nothing to look at

A data model has no gate. Run the tests, report one line, move on — the batching cap is in
`docs/process/review-gates.md`.
