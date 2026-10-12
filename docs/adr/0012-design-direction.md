# ADR-0012: Our own visual language, with Aidy as a reference and the old design system's principles kept

- **Status**: Accepted
- **Date**: 2026-10-12

## Context

Three sources pull in different directions:

1. **The previous attempt's design system** (`design-system/ibd/MASTER.md` in the archived Flutter
   repository) — mature *principles*: quiet, factual, easy to scan while tired, never show health
   scores, never use colour to mean good or bad, one primary action per screen, no decorative charts.
   But its *visual parameters* were clinical: primary `#2F6B58` (green), "do not use gradients",
   corners capped at 8px, screen title 24sp, explicitly no hero-scale text, motion limited to native
   transitions and pressed feedback.
2. **Aidy** — the maintainer rates its UI, interaction and motion, but it is another company's product
   and it displays things we have decided not to display (ADR-0009).
3. **Our brand** — the logo and banner actually in use: deep indigo → purple → magenta → pink → amber
   (ADR-0010).

The maintainer's instruction: **Aidy is a reference, not a template — derive our own style.**

## Decision

**Keep the principles.** Quiet, factual, scannable, accessible, one primary action per screen, no
scores, no colour-as-verdict, no decorative data visualisation. These come from a design system written
for exactly this patient population and they stay.

**Derive our own visual parameters**, informed by Aidy but not copied:

| Dimension | Decision |
| --- | --- |
| Colour | Our brand palette (ADR-0010). The old green/blue primary is retired. |
| Gradient | Brand asset only — logo, launch mark, and at most one onboarding moment. **Never UI chrome, never data.** |
| Corner radius | Scale 12 / 16 / 20. The old 8px cap is retired; pill shapes allowed for chips and segmented controls only. |
| Type scale | A strong page title is allowed and wanted (Aidy does this well). Still no giant decorative numerals, and no display text inside data rows. |
| Motion | Intentional, not decorative: page/sheet transitions, state changes, recording feedback. Measured values live in `docs/design/motion.md`, never guessed. |
| Cards | Cards group related facts; no nested cards. Some screens will use full-width rows + dividers where a card adds nothing. |
| Density | Standard mobile density. Whitespace groups content; oversized headings do not. |

**Aidy-specific boundary** (see also ADR-0007): we borrow structure — information architecture,
recording flows, card composition, motion rhythm. We do not borrow its palette, its assets, its copy,
its screen layouts pixel-for-pixel, or its disease-activity scoring and verdicts.

## Consequences

- `docs/design/design-tokens.md` and `docs/design/motion.md` are the working expression of this ADR;
  when they disagree with it, this ADR wins and they are updated.
- The old `MASTER.md` is **archived reference**, not a source of truth. Its principles are carried here;
  its visual parameters are retired deliberately, not by neglect.
- A design review must be able to say which of these parameters a screen is applying. "It looks nice"
  is not a review.
