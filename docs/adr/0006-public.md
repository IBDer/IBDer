# ADR-0006: The repository is public from the first commit

- **Status**: Accepted
- **Date**: 2026-10-11

## Decision

This repository is a public repository from its first commit, under Apache-2.0.

## Rejected options

- **Develop privately until v1, then open-source**: git history is not redacted automatically, so cleaning out private content later costs more and carries more risk; it also contradicts the organization's public positioning of "co-building with patients".

## Consequences

- Specs and code must withstand public scrutiny from the moment they are drafted.
- Private research source text **must not** enter this repository directly; citations must re-verify public sources.
- "Public" is an external force that constrains the quality of AI output.
