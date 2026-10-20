# Tasks: visit summary and export (M2, issue #20)

All tasks moved from the original v1 bundle remain unchecked.

## 1. Period summary

- [ ] 1.1 Agree summary content and period interaction — verify accepted examples cover both sparse records and available daily confirmations.
- [ ] 1.2 Implement deterministic generation — verify a synthetic period states its gaps, separates planned/received doses and traces each figure to records or explicit statements without a clinical conclusion.

## 2. Export and sharing

- [ ] 2.1 Agree readable layout and structured schema — verify format/version and provenance examples are documented before implementing the exporters.
- [ ] 2.2 Export both forms — verify the readable file opens and the structured file declares its version and retains record ID, type, timestamps and completeness.
- [ ] 2.3 Build explicit sharing with a prior warning — verify the warning precedes the share sheet and no background export/share occurs.

## Workflow follow-up

- Review exports with synthetic data; clinician-facing export does not satisfy encrypted backup and restore.
- Verify and sync only after the full capability is implemented.
