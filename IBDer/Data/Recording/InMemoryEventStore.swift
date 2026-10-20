import Foundation

/// A store that forgets on quit: previews, snapshot captures and UI tests.
actor InMemoryEventStore: EventStore {
    private var events: [RecordedEvent]

    init(events: [RecordedEvent] = []) {
        self.events = events
    }

    func events(in day: DayRange) async throws -> [RecordedEvent] {
        events.filter { !$0.isDeleted && day.contains($0.happenedAt) }.sorted { $0.happenedAt < $1.happenedAt }
    }

    func allEvents() async throws -> [RecordedEvent] {
        events.filter { !$0.isDeleted }.sorted { $0.happenedAt > $1.happenedAt }
    }

    func save(_ event: RecordedEvent) async throws {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }
    }

    func delete(_ id: UUID, at now: Date) async throws {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].deletedAt = now
    }

    func restore(_ id: UUID) async throws {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].deletedAt = nil
    }
}
