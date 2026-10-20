import Foundation

/// Where daily records live. The screens depend on this, never on the file format.
protocol EventStore: Sendable {
    /// Active (not deleted) records whose happened-at falls inside the day.
    func events(in day: DayRange) async throws -> [RecordedEvent]
    /// Every active record, newest first.
    func allEvents() async throws -> [RecordedEvent]
    func save(_ event: RecordedEvent) async throws
    /// Marks the record deleted. It leaves lists and counts immediately; an undo can restore it.
    func delete(_ id: UUID, at now: Date) async throws
    func restore(_ id: UUID) async throws
}

enum EventStoreError: Error, Equatable {
    /// The record was not saved. The caller must not present it as saved.
    case writeFailed(String)
    /// The file exists but cannot be read as an archive.
    case unreadableArchive(String)
    /// Written by a newer version of the app. Refuse rather than lose records.
    case unsupportedSchema(Int)
}
