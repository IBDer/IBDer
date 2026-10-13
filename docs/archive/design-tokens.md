# Design Specification: Tokens

**Status: draft, pending review.** Colors come from the organization brand and are governed by the **logo and banner actually in use** ([ADR-0010](../adr/0010-brand-source-of-truth.md)).

## Brand Colors

| Name | Hex | Usage |
| --- | --- | --- |
| Ink (deep indigo purple) | `#1B133A` | Body text, dark primary background, logo wordmark |
| Plum (purple) | `#852E83` | Primary dark |
| Magenta | `#D450B1` | Primary |
| Rose (pink) | `#F4779C` | Primary light / emphasis |
| Amber (amber orange) | `#FBB761` | Emphasis / light end of the brand gradient |
| Cocoa (dark purple brown) | `#302B50` | Secondary dark |
| Sand (apricot sand) | `#EED1B4` | Warm background / empty-state illustration |
| DustyRose (terracotta pink) | `#DE858A` | Secondary emphasis |

The brand gradient (only for the logo and very few brand moments): `#1B133A → #852E83 → #D450B1 → #F4779C → #FBB761`.

## Semantic Colors

| Token | Value | Notes |
| --- | --- | --- |
| `bg` | `#F6F5F7` | Page background |
| `surface` | `#FFFFFF` | Card |
| `textPrimary` | `#1B133A` | |
| `textSecondary` | `#6B6880` | |
| `accent` | `#852E83` | Primary action |
| `accentSoft` | `#F3E7F2` | Icon background, selected background |
| `border` | `#E6E4EA` | |

### Hard constraint: **do not use color to convey good or bad**

- Do not introduce a trend palette where "red = bad, green = improving". The color semantics of IBD symptoms turn directly into a medical judgment.
- Trend charts use the brand color ramp uniformly; whether something is abnormal is judged by the user and the doctor, not by the UI.
- The only permitted semantic color is **error / destructive action** (such as delete confirmation), unrelated to symptoms.

## Type Scale

| Token | Size / Weight | Usage |
| --- | --- | --- |
| `display` | 34 / Bold | Page title |
| `title` | 24 / Bold | Card title |
| `headline` | 17 / Semibold | Section title |
| `body` | 17 / Regular | Body text |
| `caption` | 13 / Regular | Supporting explanation |

All sizes must support Dynamic Type (use semantic fonts such as `.font(.body)`, do not hardcode point sizes).

## Spacing and Corner Radius

- Spacing scale: 4 / 8 / 12 / 16 / 24 / 32.
- Corner radius: controls 12, cards 16, large containers 20.
- Cards have no border and a very light shadow by default; do not stack hierarchy with strokes.

## Implementation Requirements

Tokens must exist **only** in `DesignSystem/Tokens/`, exposed as Swift constants. Hardcoded colors or font sizes in business code count as a violation (intercepted by a SwiftLint custom rule).
