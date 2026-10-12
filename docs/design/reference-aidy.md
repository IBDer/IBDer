# Reference teardown: Aidy

**Status: observation notes, 2026-10-12.** Method: the iOS app running on macOS ("Designed for iPad"),
observed only — window screenshots, its accessibility tree, and window-level screen recording. No
binary analysis, no asset extraction, no decryption (ADR-0007).

This file records **structure and behaviour**, not visual assets. It exists so a later refactor does
not have to rediscover them.

## Screen inventory (observed)

| Screen | What is on it |
| --- | --- |
| Launch | White field, brand mark drifting slowly (continuous, not a static image) |
| Onboarding | "Free, always" pill, very large bold heading, three feature cards with tinted icon tiles, full-width filled CTA |
| Sign-in | Email / Phone segmented tabs with an underline indicator, large rounded field, disabled button state in a washed-out tint, OR divider, black Apple sign-in button |
| Insights (home) | "Daily Brief" heading + welcome sentence, a baseline stepper (Start → Compare → First analysis → Early food insights → Baseline analysis), fact cards, a lesson card, a disease-activity card with a "What is this score?" button, a Trends section (stool patterns / symptom severity / food intake), a Medications section |
| Logs | Centred date with prev/next chevrons, empty state, a dashed "Add a note about today" field, a dashed "Daily Check-in — Tap to complete" row, five log-type chips (Stool / Symptoms / Meals / PRNs / Labs), a "Describe your food…" input with a camera button |
| Chat | AI chat tab |
| Profile | Avatar + name, feedback card, a **filled pill** segmented control (Your Profile / App Settings), condition card, a long chip list of trackable symptoms |

## What is worth borrowing

- **The chip row as the recording entry point.** Five equally weighted entry types, one tap each,
  living above a persistent input. This matches our four peer event types (ADR-0001) far better than a
  single "record" button would.
- **The dashed "tap to complete" row** for the daily check-in: it reads as "unfinished", not as a
  button, which is exactly the affordance our `DailyConfirmation` needs.
- **Chip-based multi-select** for symptom sets — cheap to scan, cheap to change.
- **Empty states that state the next action** ("No logs for this day yet — start by completing your
  daily check-in or logging some food") rather than a bare illustration.
- **The date header with prev/next chevrons** for moving through days.

## What we do not borrow

- The **disease-activity card**: a score, a "Remission" verdict, and a "Trending: Unclear" label on the
  home screen. That is exactly what ADR-0009 forbids, and it is the clearest argument for having
  written ADR-0009 down.
- Its **palette and assets** (ADR-0010 governs ours).
- Its **English copy as copy** — structure only.

## Interaction critique (three concrete findings)

1. **Two different segmented controls in one product.** Sign-in uses underline tabs; Profile uses a
   filled pill. Pick one pattern per meaning and keep it.
2. **The Logs screen stacks three bottom bars** — five log chips, a text input, and the tab bar. On a
   545pt-tall window the space left for actual records is small. Our version must let the record list
   own the screen and keep the entry row to one line.
3. **A conclusion-shaped card at the top of the home screen** ("symptoms were mild, suggesting
   stability") makes the product read as an assessor rather than a recorder. Beyond the compliance
   question, it is also fragile: one missed day changes what it says.

## Motion: measurement, and an honest caveat

Method: the standard procedure in [motion.md](motion.md), applied to this app — a window-level
recording, then frame extraction and a frame-to-frame difference timeline to locate transitions.

What the measurement showed:

- one transition burst around **t≈2.2–2.4 s lasting ≈200 ms**, with a decaying profile — consistent
  with a spring rather than a linear curve;
- one **single-frame hard cut** (no animation at all) at a tab switch;
- everything else static.

**Caveat, and why the numbers are not in `motion.md` yet:** window-level recording duplicates frames,
so the effective temporal resolution is far below the nominal 120 fps (116 of 1801 frames carried any
change, maximum frame-to-frame difference 5.99/255). Durations measured this way are indicative, not
authoritative. A device-level recording at a known frame rate is required before any value is written
into the spec.

## Consequence for us

The teardown gives us **structure** (entry row, check-in affordance, date navigation, chip sets, empty
state copy) and **three interaction lessons**. It does not give us numbers we can build motion from —
those still have to be measured from a clean recording, or chosen and then verified against our own
build.
