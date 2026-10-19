# Design Specification: Motion

**Status: draft.** The measured values for durations and curves are still to be filled in (see the method at the end).

## Principles

1. **Motion serves "remembering faster", not decoration.** Every animation must be able to answer "what did it help the user understand".
2. **Restrained by default.** The first version uses only three kinds of motion: hierarchy transitions, state feedback, and number changes.
3. **"Reduce Motion" must be respected**; when it is on, motion degrades to cross-fade, with no translation or scaling.
4. No decorative looping animations (except the brand launch animation, and that plays only once).
5. Animation must not block input; the user can keep interacting mid-animation.

## Duration scale (placeholders — **not measurements**)

The numbers below are starting points chosen by hand. They are **not** measurements, and presenting a
guess as a measurement is forbidden by [ADR-0012](../adr/0012-design-direction.md) and by the
`ibder-design` skill. A screen does not pass design review on placeholder values; measure it with the
procedure at the end of this file and replace the row.

| Scenario | Duration | Curve |
| --- | --- | --- |
| Tap feedback | 100 ms | ease-out |
| State change (selection, toggle) | 180 ms | spring(response 0.28, damping 0.86) |
| Page push / pop | 300 ms | system default |
| Half-screen sheet in / out | 320 ms | spring(response 0.34, damping 0.88) |
| Number / chart change | 400 ms | ease-in-out |

## Haptic Feedback

- Successful record: one light tap (`.light`).
- Confirmation of a destructive action such as delete: warning.
- Do not give feedback for scrolling, hovering, or every tap.

## Accessibility

- When "Reduce Motion" is on: all translation and scaling become cross-fades (≤ 150 ms).
- Chart value changes must not be conveyed by animation alone; text and accessible labels are required.

## Measurement Method (this repository's standard procedure)

1. Record with the iPhone's built-in screen recording (60 fps, 16.7 ms between frames) or `screencapture -v` for a window.
2. `ffmpeg -i in.mov -vf fps=60 frames/%05d.png` to export frame by frame.
3. Count the animation's starting and ending frames → duration = frame count ÷ frame rate; measure the peak overshoot → derive the spring's damping.
4. Write the results back into this file, and note the measured device model and recording frame rate.

**To be filled in**: the measured durations for the key flows of a comparable product (Aidy), and our own first version's corresponding values.
