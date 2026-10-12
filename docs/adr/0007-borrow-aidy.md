# ADR-0007: Learn from Aidy's product design, do not copy its assets or its conclusions

- **Status**: Accepted — expanded 2026-10-12
- **Date**: 2026-10-11, revised 2026-10-12

## Context

The maintainer rates Aidy's motion design highly and wants v1 to lean on it **more**, because our own
UI, interaction model, and content structure are not settled yet and a later refactor is expected.
Aidy also demonstrates things we have decided **not** to do — it displays automatically calculated
HBI / SCCAI and a "Remission" verdict (see ADR-0009).

## Decision

**Borrow, as a product-design reference:**
- **Motion language**: durations, curves, stagger, empty-state treatment, transition types.
- **Layout rhythm and hierarchy**: card geometry, spacing scale, CTA prominence, large-weight headings.
- **Information architecture and recording flows**: the log-type entry row, the daily check-in ramp,
  the "today" timeline, chip-based multi-select, the profile/settings split.
- **Content structure**: what a suggestion card contains, how a report is organised — structure only,
  never wording.

**Do not borrow:**
- **Visual identity**: colours, logo, iconography (ADR-0010 governs the palette).
- **Pixel-level replication** of screens.
- **Assets, code, or copy** taken from the app or its binary.
- **Disease-activity scores, thresholds, or verdict-style conclusions** (ADR-0009).
- **Food-causality claims.**

**Method**: analysis happens on the running app by observation only — screenshots, the accessibility
tree, and screen recording. No binary analysis, no asset extraction, no decryption, no runtime hooking
of the production app.

## Consequences

- Design work must produce **our own spec**: screen inventory, a motion spec with measured values, and
  an interaction critique. That spec is what we hand to the next agent, so a refactor does not start
  from zero. The maintainer's reason for borrowing is exactly this: handoff speed.
- Aidy's English copy is a structural reference only; our Chinese UI strings are written by us.
- Where Aidy's structure implies a capability we have deferred (biologic scheduling), we borrow the
  *layout pattern*, not the feature.
