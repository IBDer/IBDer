# Process: CI and Delivery

**Status: draft, pending review.**

## Current state

- **There is no paid Apple Developer account**, so the first version does not do physical-device distribution or TestFlight.
- Development and verification happen on a local macOS: the iOS Simulator target can be built, and the app can also run directly on the Mac as "Designed for iPad", without signing.

## CI goals (GitHub Actions, macOS runner)

1. Check out the code.
2. Detect whether an Xcode project exists: if not, skip the build steps (stay green during the skeleton phase).
3. Once a project exists: `xcodebuild build` + `xcodebuild test` (Simulator target, no signing needed).
4. SwiftFormat / SwiftLint checks.

## Branch protection

- `main` requires a PR to merge, and CI must be green.
- agents do not merge on their own.

## Delivery cadence

- A human applies one tag per archived change.
- If TestFlight is introduced in the future, the following must be decided first: who holds the developer account, how certificates and provisioning profiles are managed, and whether testing is public. **This is a separate decision, out of scope for the first version.**

## Secrets

- Certificates, provisioning profiles, and API keys must not appear in the repository.
- When secrets are needed, use GitHub Actions secrets and record their purpose in the documentation.
