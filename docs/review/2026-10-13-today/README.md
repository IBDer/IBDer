# Review screenshots: the Today screen

Captured 2026-10-13 on an iPhone 17 simulator (iOS 27), from commit
`impl: project skeleton and design tokens` + the Today screen slice.

| File | State | How to reproduce |
| --- | --- | --- |
| `01-with-records.png` | A day with four recorded facts | `xcode_run action=run` |
| `02-empty-day.png` | A day with nothing recorded yet | launch with the argument `-emptyDay` |

Everything visible is **synthetic sample data** (`RecordedEvent.sample`) — no real record exists in
this repository (AGENTS.md §4).

## What to look at

1. Can you tell, in one second, **what today contains** and **where to record the next thing**?
2. The four entry points (如厕 / 饮食 / 用药 / 输液) are meant to read as **equal in weight** (ADR-0001).
   Does anything make one look more important than the others?
3. The dashed 每日确认 row is meant to read as "an unfinished thing waiting for you", not as a button.
4. Is anything too small, too grey, or too cramped to use while unwell?

These screenshots are review artifacts, not product assets; they are replaced whenever the screen
changes (see docs/process/review-gates.md).
