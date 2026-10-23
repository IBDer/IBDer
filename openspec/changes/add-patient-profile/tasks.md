# Tasks: the patient profile (M1)

## 1. Profile facts (issue to be opened)

- [x] 1.1 Implement the profile value and its store — PatientProfileTests: round-trip through a reopened file, a failed write leaves the previous profile, a missing file is an empty profile.
- [x] 1.2 Build the three-page onboarding — an XCUITest skips all three pages and lands on a usable day screen.
- [x] 1.3 Ask the disease state as the doctor's statement — `unsure` is the default and no code reads the value except to display it.
- [x] 1.4 Show and edit the profile from the settings tab — the same three pages open as a sheet; saving writes the same file the onboarding wrote.
- [x] 1.5 Verified at the largest text size and in the dark appearance; captures are in `docs/review/2026-10-23-accessibility/`.

## Workflow follow-up

- The biologic plan reads the weight from here; no other capability may.
- Open the issue before implementing, as AGENTS.md section 8 requires.
