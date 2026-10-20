import Foundation

/// Rules about when a record may be saved. Pure functions, testable without a screen or a store.
enum RecordingPolicy {
    /// Small clock differences must not block a save made now.
    static let futureTolerance: TimeInterval = 5 * 60

    /// Any past moment is acceptable; the future is not, except within the tolerance.
    static func accepts(happenedAt: Date, now: Date) -> Bool {
        happenedAt <= now.addingTimeInterval(futureTolerance)
    }
}

/// Counts over one day's records. A count never includes a deleted record or an urge-only event.
enum DayTotals {
    static func bowelMovements(in events: [RecordedEvent]) -> Int {
        events.filter { !$0.isDeleted && $0.payload.toiletEvent?.isBowelMovement == true }.count
    }
}
