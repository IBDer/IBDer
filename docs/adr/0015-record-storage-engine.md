# ADR-0015: One versioned JSON archive, written atomically, instead of SwiftData

- **Status**: Accepted
- **Date**: 2026-10-20

## Context

The recording change needs local storage that survives relaunch, reports a failed write instead of
pretending to save, and keeps previously saved records across schema changes. The design note had
assumed SwiftData; nothing in ADR-0003 requires it, and the dataset is one person's daily records —
hundreds to a few thousand entries over a year.

## Decision

Store the records in a single JSON archive under Application Support:

- `FileEventStore` is an actor; the file carries a `schemaVersion` and an array of records.
- A save encodes the whole archive and writes it with `Data.write(options: .atomic)`. The in-memory
  copy is replaced only after the write succeeds, so a failed write cannot look like a saved record.
- A file from a newer schema is refused rather than overwritten. A corrupt file is reported, never
  silently replaced.
- Records are value types with stable coding keys; `revision` history and `deletedAt` travel in the
  same record, so an undo restores the same record rather than a copy.

## Alternatives

- **SwiftData**: brings a query layer we do not need at this size, and adds a framework's migration
  and concurrency behaviour to a surface we must be able to reason about completely. Revisit if the
  data grows past what one file can hold comfortably.
- **SQLite directly**: same benefit with more code; the export for a clinician is a file, not a
  database.
- **App Group / Documents directory**: Application Support is the correct place for data the user
  does not manage as files.

## Consequences

- Back-up means copying one file, and the future encrypted export can encrypt this archive directly.
- Every write is O(n) in the number of records. At dogfood scale that is irrelevant; a later switch
  to per-day files is a contained change behind `EventStore`.
- The archive format is pinned by a fixture test: if a previously saved file stops opening, CI says so.
