# ADR-0010: Brand visuals follow the logo and banner actually in use

- **Status**: Accepted
- **Date**: 2026-10-12

## Context

The status of `project-context/decisions/brand-direction.md` says "logo deferred", and its primary color direction is described as terracotta / apricot / cocoa / aubergine. But the organization enabled a new logo and homepage banner on **2026-10-10** (commit message `brand: replace profile banner with new IBDer logo`).

The two correspond only partially, which leaves `docs/design/design-tokens.md` with "two sources of truth".

## Decision

**Brand visuals follow the logo and banner actually in use** (the organization homepage's current asset `profile/assets/ibder-profile-banner.jpg`, updated 2026-10-10). The palette is measured from that asset:

`#1B133A` · `#2E1B4A` · `#302B50` · `#6C3474` · `#852E83` · `#9C42A4` · `#A85593` · `#D450B1` · `#DE858A` · `#F4779C` · `#FBB761` · `#EED1B4`

The "warm terracotta / apricot / cocoa / aubergine" description and the "logo deferred" status in `brand-direction.md` are treated as **superseded historical records**.

## Consequences

- The brand colors in `docs/design/design-tokens.md` match these, and a second source is no longer needed.
- The **logo prohibition list and tone words** in `brand-direction.md` **remain in effect** — they constrain future icon work and do not lapse because the logo was changed.
- If brand assets are changed again in the future, update this ADR rather than adding a parallel source of truth.
