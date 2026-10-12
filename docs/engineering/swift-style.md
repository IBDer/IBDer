# Swift Code Style

**Status: draft, pending review.** Principle: **enforce with tooling, not with memory.**

## Enforced Tooling

| Tool | Purpose | When it runs |
| --- | --- | --- |
| SwiftFormat | Formatting (indentation, line breaks, sorting) | On save + CI |
| SwiftLint | Rule checks (force unwrap forbidden, etc.) | On save + CI |

The configuration is added together with the first Xcode project, and the configuration itself is also reviewed.

## Rules

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- 4-space indentation, 120 line width.
- **`!` force unwrapping is forbidden** (tests and `@IBOutlet` excepted); use `guard let` to return early.
- Prefer `let`; type inference versus explicit types is decided by readability, and public APIs annotate types explicitly.
- Express errors with `throws` + a concrete error type; do not use `Optional` to represent the reason for failure.
- Concurrency: Swift 6 strict concurrency; types passed across actors must be `Sendable`; UI state lives on the main actor.
- Do not write parameters and branches that "might be useful later".
- Comments state **why**, not **what**; comments are written in English.

## Naming

See [naming.md](naming.md). Identifiers must come from [CONTEXT.md](../../CONTEXT.md).

## Localization

- UI strings always go through String Catalog, never hardcoded.
- The first version is Chinese; Chinese string literals do not appear in code (test assertions excepted).
