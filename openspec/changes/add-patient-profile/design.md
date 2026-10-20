# Design: the patient profile

## Context

See proposal.md. The app currently stores only recorded events; nothing identifies the person, their
diagnosis or their weight. M1's biologic card needs a weight, and the settings tab needs somewhere to
put the facts a patient wants to see once in a while.

## Goals / Non-Goals

Keep a small, honest set of self-reported facts. This change does not model disease activity, does not
calculate a score, and does not sync anything off the device.

## Decisions

- **A separate file and store.** The profile is not an event: it has one value, it is edited in place,
  and it must survive a record-archive change without being entangled. `ProfileStore` writes
  `profile.json` with the same versioned, atomic pattern as `FileEventStore` (ADR-0015).
- **Three pages, each skippable.** Body, disease, treatment. A patient who is not ready to say what
  they have can still record a toilet event in the first minute.
- **The disease state is quoted, not judged.** The question is "what does your doctor say", with
  `unsure` as the default. The value is stored and displayed; it never enters a calculation.
- **Treatment is a set, not a ladder.** Biologic, oral medication, exclusive enteral nutrition,
  partial enteral nutrition, other diet, none — a patient may be on two of them at once.
- **Complications are broad groups.** Perianal, skin, joints, eyes, mouth ulcers, liver and biliary,
  anaemia or nutrition. The group is what a patient can answer; the specific diagnosis is the care
  team's.
- **Weight is a number with a unit, not a trend.** It is stored in kilograms, entered in kilograms,
  and only read when a biologic plan asks for it. No BMI, no target, no judgement.

## Risks / Trade-offs

- [A profile invites inference] -> Nothing is derived from height and weight. If a future feature wants
  to, it needs its own decision.
- [Skipped onboarding leaves the app half-configured] -> The biologic flow falls back to asking for a
  weight at the point it is actually needed.
- [A stale weight gives a wrong suggestion] -> The calculation names the weight and the date it was
  entered, and the recorded dose is always the amount the hospital prepared.

## Slice decisions

Agreed with the maintainer on 2026-10-20: skippable pages, three pages, doctor-quoted disease state
with `unsure` by default, six treatment options, seven complication groups (listed in the spec),
weight used only for biologic dose calculation.
