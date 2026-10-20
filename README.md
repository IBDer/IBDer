# IBDer App

A self-management tool for Patients with Crohn's disease (CD) and ulcerative colitis (UC): it records meals, bowel movements, medication, symptoms and care events, and organises the facts of a period of time into a VisitSummary that can be brought into the clinic.

> **Current status: implementation has started.** The repository conventions and the first OpenSpec
> change are merged; the first implementation slice (project skeleton, design tokens) is in review.
> The rule that got us here still holds: specification first, then requirements, then code.

## Phases

| Phase | Status |
| --- | --- |
| Repository conventions / design specifications / CI / testing approach | Merged |
| Requirements and scope (the first OpenSpec change) | Merged — 36 tracked tasks, 4 done (`openspec/changes/add-v1-recording-core/`) |
| Application code | Recording core in progress — see the [milestones](https://github.com/IBDer/IBDer/milestones) |

## Build

The Xcode project is **generated, not committed** ([ADR-0013](docs/adr/0013-generated-xcode-project.md)):

```bash
brew install xcodegen swiftlint swiftformat
xcodegen generate
open IBDer.xcodeproj          # or: xcodebuild test -scheme IBDer -destination 'platform=iOS Simulator,name=iPhone 17'
```

Lint before pushing: `swiftformat --lint . && swiftlint --strict`.

## Medical boundaries

This project **does not currently preset** medical safety red lines — the relevant constraints are decided feature by feature and recorded as their own ADR (see [ADR-0008](docs/adr/0008-no-standing-red-lines.md)).

But the following areas **must be explicitly decided by a human maintainer before implementation**, and must not be built first and asked about later:

- Diagnosis, individualised treatment advice, remote consultations or emergency triage
- Disease activity scores, and conclusive output such as "remission / active / relapse"
- Causal statements between food and symptoms
- Patient community UGC
- Names, wording, images and translations of clinical scales

On the data side this always holds: identifiable Patient information must **not** appear in the repository, Issues, Discussions, logs, screenshots, or test data.

Public rules from [IBDer/.github](https://github.com/IBDer/.github) and [IBDer/research](https://github.com/IBDer/research) bind this repository **only once a human has verified them**. None of them is verified yet — see [docs/inherited-documents.md](docs/inherited-documents.md).

## Documentation map

| What you want to know | Where to look |
| --- | --- |
| How agents work in this repository | [AGENTS.md](AGENTS.md) |
| Domain terminology (identifiers and definitions) | [CONTEXT.md](CONTEXT.md) |
| Why it was decided this way | [docs/adr/](docs/adr/) |
| How the work moves (the loop, the two gates) | [docs/process/review-gates.md](docs/process/review-gates.md) |
| Process (OpenSpec / review / testing / CI) | [docs/process/](docs/process/) |
| Current system behavior (single source of truth) | [openspec/specs/](openspec/specs/) |
| Changes in progress | [openspec/changes/](openspec/changes/) |

## License

Software code uses Apache-2.0, see [LICENSE](LICENSE). Research and documentation in the organisation use CC BY 4.0.
