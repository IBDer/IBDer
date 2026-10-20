import Foundation

/// One recorded fact, with its provenance.
///
/// `happenedAt` (when it happened) and `recordedAt` (when it was entered) are separate on purpose:
/// a backfilled record is a different fact from one entered at the time.
struct RecordedEvent: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    var happenedAt: Date
    let recordedAt: Date
    var completeness: Completeness
    var payload: RecordPayload
    /// Previous values, oldest first. The original `recordedAt` is never rewritten.
    var revisions: [Revision]
    /// Set when the patient deletes the record, so an undo can restore the same record.
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        happenedAt: Date,
        recordedAt: Date = .now,
        completeness: Completeness = .everyOne,
        payload: RecordPayload
    ) {
        self.id = id
        self.happenedAt = happenedAt
        self.recordedAt = recordedAt
        self.completeness = completeness
        self.payload = payload
        revisions = []
        deletedAt = nil
    }

    var isDeleted: Bool {
        deletedAt != nil
    }

    var kind: RecordKind {
        payload.kind
    }

    /// A record entered on a different local day from when it happened.
    func isBackfilled(calendar: Calendar = .current) -> Bool {
        !calendar.isDate(happenedAt, inSameDayAs: recordedAt)
    }

    struct Change: Sendable, Equatable {
        var payload: RecordPayload?
        var happenedAt: Date?
        var completeness: Completeness?
    }

    /// Returns an edited copy. When anything actually changes, the previous state is kept in
    /// `revisions` so a later summary can explain what changed.
    func applying(_ change: Change, at now: Date) -> RecordedEvent {
        let payload = change.payload ?? payload
        let happenedAt = change.happenedAt ?? happenedAt
        let completeness = change.completeness ?? completeness

        guard payload != self.payload
            || happenedAt != self.happenedAt
            || completeness != self.completeness
        else { return self }

        var copy = self
        copy.revisions.append(
            Revision(
                replacedAt: now,
                happenedAt: self.happenedAt,
                completeness: self.completeness,
                payload: self.payload
            )
        )
        copy.payload = payload
        copy.happenedAt = happenedAt
        copy.completeness = completeness
        return copy
    }
}

/// What a record looked like before an edit.
struct Revision: Codable, Sendable, Equatable {
    var replacedAt: Date
    var happenedAt: Date
    var completeness: Completeness
    var payload: RecordPayload
}
