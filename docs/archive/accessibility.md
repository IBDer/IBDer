# Design Specification: Accessibility and Usability

**Status: draft, pending review.**

## Why the Bar Is Higher Here

Target users will use it **while symptoms are active**: abdominal pain, urgency, fatigue, possibly one-handed, possibly on a small screen, possibly wanting to spend only 5 seconds.

## Hard Requirements

| Item | Requirement |
| --- | --- |
| Dynamic Type | Supports the largest setting without truncation or overlap; the core recording flow can still be completed at the largest font size |
| VoiceOver | Every interactive element has a label; charts have point-by-point accessible labels and a text summary |
| Contrast | Body text ≥ 4.5:1, large text ≥ 3:1 |
| Touch target | ≥ 44×44 pt |
| Reduce Motion | Translation and scaling degrade to cross-fade |
| One-handed reach | Core recording actions can be completed in the lower half of the screen |
| Color | Never rely on color alone to convey information (no red/green for good or bad) |

## Minimum Bar for the Core Flow

"Record one ToiletEvent" must satisfy:

- Entered from any main screen and the record completed in **a single tap** (time defaults to now, the rest optional).
- At the largest font size + one-handed + dark mode, no occlusion and no small targets that require precise tapping.
- After an interruption (incoming call, backgrounding), returning loses none of the content already entered.

## Verification

- Every change that touches UI must state in its acceptance criteria the behavior at the **largest Dynamic Type**.
- The key flow is covered by a UI test on one path: "cold launch → record → back".
