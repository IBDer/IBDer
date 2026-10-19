# ADR-0013: The Xcode project is generated from a committed project.yml

- **Status**: Accepted
- **Date**: 2026-10-13

## Context

The repository is written mostly by agents. An Xcode project file (`.pbxproj`) is a large generated
plist with unstable ordering: two people (or two agents) touching different targets produce a conflict
that has to be resolved by hand, and a reviewer cannot read what changed.

## Decision

- **XcodeGen** describes the project in `project.yml`, which is committed and reviewed like any other file.
- `IBDer.xcodeproj` is **generated and git-ignored**. Anyone who wants to open the project runs
  `xcodegen generate` first.
- CI runs `xcodegen generate` before building, so the committed definition is the only source.

## Rejected options

- **Commit the `.pbxproj`**: unreviewable diffs and routine merge conflicts, in a repository whose main
  authors are agents.
- **Tuist**: comparable capability, heavier toolchain and a Swift manifest to maintain, for one app
  target and one test target.
- **Hand-maintain the project**: same problems as committing a `.pbxproj`, plus it drifts from the
  folder layout that `docs/engineering/architecture.md` fixes.

## Consequences

- Adding a file or a target means editing `project.yml`; adding a Swift file under `IBDer/` needs no
  change at all, because the target's source path is a directory.
- A fresh clone cannot build until `xcodegen generate` runs once. The README states this, and CI does it.
- The trade is deliberate: one extra command, in exchange for a project definition a human can read in
  a pull request.
