# ADR-0011: The project language is English; only product strings are localised

- **Status**: Accepted
- **Date**: 2026-10-12

## Context

The repository started with Chinese documentation. The maintainer wants the project to be
international: everything produced by the project — code, documentation, ADRs, specs, commit
messages, pull requests, issues — is easier to hand over, review, and search in one language.

## Decision

- **English is the project language.** Documentation, ADRs, OpenSpec specs, code identifiers,
  code comments, commit messages, PR and issue text, and branch names are written in English.
- **The only Chinese content is product-facing**: UI strings shown when the app language is Chinese.
  Those live in the String Catalog (`zh-Hans`), never in documentation, comments, or code literals.
- **Historical Chinese documents are translated, not kept in parallel.** Where a translation could
  change meaning, the English text wins from the moment it is committed.
- **Research material** (the private `project-context` repository) is source material, not project
  output; translating it is a separate decision, tracked outside this ADR.

## Consequences

- Existing Chinese docs are translated in place; git history keeps the original wording.
- CONTEXT.md lists English identifiers with the Chinese UI label as a localisation note.
- Reviewers should not accept new Chinese documentation, except the String Catalog.
