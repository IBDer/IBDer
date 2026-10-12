# ADR-0002: iOS native, local-first

- **Status**: Accepted
- **Date**: 2026-10-11

## Decision

The first version is a native iOS app (SwiftUI), with local-first data, no self-hosted backend, and no account system.

## Rejected options

- **WeChat Mini Program**: the widest reach, but it introduces entity qualifications, regulatory filing, a server side, and entrusted-processor agreements — the largest compliance surface — and it cannot carry native animations or local encrypted storage.
- **Don't write software yet**: it cannot validate real recording behavior.

## Consequences

- China's Android user share is high, and the first version cannot cover most patients. This is an **explicitly accepted cost**: the goal of the first version is to validate the recording model, not to reach scale.
- The reach form (Mini Program / Web) is left to be decided after first-version validation.
- During development it can be run directly on macOS as an iOS app, with no paid developer account.
