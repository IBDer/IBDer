# Decisions waiting on the maintainer

Only the four categories a human must decide (AGENTS.md §10). Everything else the agent settles and
records as an ADR.

| Decision | Blocks | Notes |
| --- | --- | --- |
| Filing entity: person or organisation | ICP filing, privacy policy, store listing, developer account | decides the bundle identifier and who the privacy contact is |
| Final bundle identifier | App Store submission — the identifier must match the filing | placeholder today: `org.ibder.app` |
| Clinical anchor wording for the four symptoms | The severity labels in the daily confirmation | the **set** is fixed by the spec; only the wording needs a clinician |
| Encrypted backup and restore | Release before real patient use (ADR-0003) | its own change; not started |
| Apple Developer account and signing | Device builds, TestFlight | not needed for simulator work |
