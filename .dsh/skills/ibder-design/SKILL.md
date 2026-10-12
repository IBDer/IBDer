---
name: ibder-design
description: >
  Design and review IBDer app screens, components, motion and tokens. Use whenever a task touches
  UI, layout, navigation, animation, colour, typography, empty states, accessibility of a screen, or
  when someone asks "does this look right", "review this screen", "make this feel better", or wants to
  borrow a pattern from another app. Also use before implementing any screen from a spec.
---

# IBDer design

You are designing for a patient who may be in pain, fatigued, or standing in a hospital corridor.
Everything below exists to make recording fast and reading honest.

## Read first

1. `docs/adr/0012-design-direction.md` — the visual direction and why the old system's parameters were retired
2. `docs/adr/0007-borrow-aidy.md` — what may be borrowed from a reference product, and what may not
3. `docs/adr/0009-no-scores-in-v1.md` — the line the interface must not cross
4. `docs/design/design-tokens.md` + `docs/design/motion.md` + `docs/design/accessibility.md`
5. `CONTEXT.md` — every label you invent must use its vocabulary

## Non-negotiables

- **Facts, never conclusions.** Show what the patient recorded. Never a score, a severity verdict, a
  trend verdict, or a probability. If a design idea needs one, stop and raise it as a decision.
- **Never colour-as-verdict.** No red/green semantics for symptoms. Trend charts use the brand scale.
- **Never render "no record" as "no symptom".** Missing data has its own visual state and its own words.
- **Tokens only.** No hard-coded colour, font size, radius, or spacing in a screen; they come from
  `DesignSystem/Tokens`.
- **Identifiers and labels** come from `CONTEXT.md`; the Chinese UI string lives in the String Catalog.
- **Every recording path** is reachable in one tap from where the patient already is.

## The design loop

1. **Inventory before drawing.** List the screens and states the change touches, including empty,
   partial, error, and off-line states. A screen without its empty state is not designed.
2. **Write the content first.** Decide the words (Chinese UI copy) and the information hierarchy before
   choosing a layout. If the copy needs a conclusion, the design is wrong.
3. **Compose from tokens.** Use the existing components; if a new one is needed, add it to
   `DesignSystem/Components` and note why in the change.
4. **Specify motion by measurement, not by adjective.** Any animation gets a duration, a curve, and a
   reason. Measure a reference with the method in `motion.md` (screen recording, frame stepping) —
   never invent numbers.
5. **Verify on a device.** Screenshot the result at the largest Dynamic Type, in dark mode, with Reduce
   Motion on. Use the simulator tooling available in this harness, or run the app on the Mac.
6. **Review with the checklist below** and record the outcome in the change.

## Borrowing from a reference app

Structure yes, surface no. Concretely: borrow information architecture, entry-point placement, card
composition, the rhythm of a transition, the shape of an onboarding ramp. Never borrow colour, assets,
iconography, copy, or a screen reproduced layout-for-layout. And never borrow a feature that crosses
ADR-0009 just because the reference has it.

## Review checklist

- [ ] Every screen in the change has empty / partial / error states designed
- [ ] One primary action per screen; secondary actions are visually subordinate
- [ ] Touch targets ≥ 44pt; primary recording action reachable one-handed
- [ ] Largest Dynamic Type: no truncation, no overlap, core flow still completable
- [ ] VoiceOver: every interactive element labelled; charts have a text summary
- [ ] Reduce Motion: movement degrades to a cross-fade; nothing essential is conveyed by motion alone
- [ ] Contrast ≥ 4.5:1 body, ≥ 3:1 large text
- [ ] No colour used to mean good/bad; no score, verdict, or probability anywhere
- [ ] Missing data visually distinct from zero
- [ ] Motion values come from measurement, not taste
- [ ] No hard-coded token values in the screen
- [ ] Copy passes the test: is this a fact the patient recorded, or a conclusion we reached?
