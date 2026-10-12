# IBDer App

A self-management tool for Patients with Crohn's disease (CD) and ulcerative colitis (UC): it records meals, bowel movements, medication, symptoms and care events, and organises the facts of a period of time into a VisitSummary that can be brought into the clinic.

> **Current status: specification and requirements definition phase; no application code has been written yet.**
> Define the specification first, then the requirements, and only then write code.

## Phases

| Phase | Status |
| --- | --- |
| Repository conventions / design specifications / CI / testing approach | Under review |
| Requirements and scope (the first OpenSpec change) | Not started |
| Application code | Not started |

## Medical boundaries

This project **does not currently preset** medical safety red lines — the relevant constraints are decided feature by feature and recorded as their own ADR (see [ADR-0008](docs/adr/0008-no-standing-red-lines.md)).

But the following areas **must be explicitly decided by a human maintainer before implementation**, and must not be built first and asked about later:

- Diagnosis, individualised treatment advice, remote consultations or emergency triage
- Disease activity scores, and conclusive output such as "remission / active / relapse"
- Causal statements between food and symptoms
- Patient community UGC
- Names, wording, images and translations of clinical scales

On the data side this always holds: identifiable Patient information must **not** appear in the repository, Issues, Discussions, logs, screenshots, or test data.

Organisation-level public rules are governed by the **verified** content in [IBDer/.github](https://github.com/IBDer/.github) and [IBDer/research](https://github.com/IBDer/research).

## Documentation map

| What you want to know | Where to look |
| --- | --- |
| How agents work in this repository | [AGENTS.md](AGENTS.md) |
| Domain terminology (Chinese / code identifiers) | [CONTEXT.md](CONTEXT.md) |
| Why it was decided this way | [docs/adr/](docs/adr/) |
| Engineering conventions (architecture / style / naming / logging) | [docs/engineering/](docs/engineering/) |
| Design specifications (color / motion / accessibility) | [docs/design/](docs/design/) |
| Process (OpenSpec / review / testing / CI) | [docs/process/](docs/process/) |
| Current system behavior (single source of truth) | [openspec/specs/](openspec/specs/) |
| Changes in progress | [openspec/changes/](openspec/changes/) |

## License

Software code uses Apache-2.0, see [LICENSE](LICENSE). Research and documentation in the organisation use CC BY 4.0.
