import Foundation
import Observation

/// The screen state: which day is on screen, that day's records, and the one deletion the patient
/// can still undo. Nothing here knows how a record is drawn.
@MainActor
@Observable
final class RecordsModel {
    private let store: any EventStore
    private(set) var day: Date
    private(set) var events: [RecordedEvent] = []
    private(set) var lastDeleted: RecordedEvent?
    /// The last few distinct medications, newest first — so the same tablet is not retyped daily.
    private(set) var recentMedications: [MedicationEvent] = []
    var failure: String?
    private var loadedDay: Date?

    init(store: any EventStore, day: Date = .now, events: [RecordedEvent] = []) {
        self.store = store
        self.day = day
        self.events = events
        if !events.isEmpty {
            loadedDay = day
        }
    }

    /// The store the app runs on. `-inMemory` keeps a launch free of persisted state, which is what
    /// UI tests and snapshot captures use.
    static func live() -> RecordsModel {
        if ProcessInfo.processInfo.arguments.contains("-inMemory") {
            return RecordsModel(store: InMemoryEventStore())
        }
        if let store = try? FileEventStore.appStore() {
            return RecordsModel(store: store)
        }
        return RecordsModel(store: InMemoryEventStore())
    }

    func load() async {
        do {
            events = try await store.events(in: DayRange.containing(day))
            loadedDay = day
        } catch {
            failure = String(describing: error)
        }
    }

    /// Every active record, for the trends screen.
    func allEvents() async -> [RecordedEvent] {
        await (try? store.allEvents()) ?? []
    }

    func loadIfNeeded() async {
        guard loadedDay != day else { return }
        await load()
        await refreshRecentMedications()
    }

    private func refreshRecentMedications() async {
        guard let all = try? await store.allEvents() else { return }
        var seen = Set<String>()
        var result: [MedicationEvent] = []
        for event in all {
            guard case let .medication(medication) = event.payload,
                  !medication.name.isEmpty,
                  seen.insert(medication.name).inserted
            else { continue }
            result.append(medication)
            if result.count == 3 {
                break
            }
        }
        recentMedications = result
    }

    func show(_ date: Date) async {
        let target = Calendar.current.startOfDay(for: date)
        guard target != day else { return }
        day = target
        await load()
    }

    /// After a write: show the day the fact belongs to and reload it, even when that day is already
    /// on screen. Reloading is the point — a save on the visible day used to leave the list stale.
    private func refresh(after date: Date) async {
        let target = Calendar.current.startOfDay(for: date)
        if target != day {
            day = target
        }
        await load()
    }

    func step(_ days: Int) async {
        guard let target = Calendar.current.date(byAdding: .day, value: days, to: day) else { return }
        await show(target)
    }

    func save(toilet: ToiletEvent, at happenedAt: Date, editing: RecordedEvent?) async -> Bool {
        let event: RecordedEvent = if let editing {
            editing.applying(.init(payload: .toilet(toilet), happenedAt: happenedAt), at: .now)
        } else {
            RecordedEvent(happenedAt: happenedAt, payload: .toilet(toilet))
        }
        do {
            try await store.save(event)
            await refresh(after: event.happenedAt)
            return true
        } catch {
            failure = String(describing: error)
            return false
        }
    }

    func save(meal: MealEvent, at happenedAt: Date, editing: RecordedEvent?) async -> Bool {
        let event: RecordedEvent = if let editing {
            editing.applying(.init(payload: .meal(meal), happenedAt: happenedAt), at: .now)
        } else {
            RecordedEvent(happenedAt: happenedAt, payload: .meal(meal))
        }
        do {
            try await store.save(event)
            await refresh(after: event.happenedAt)
            return true
        } catch {
            failure = String(describing: error)
            return false
        }
    }

    func save(medication: MedicationEvent, at happenedAt: Date, editing: RecordedEvent?) async -> Bool {
        let event: RecordedEvent = if let editing {
            editing.applying(.init(payload: .medication(medication), happenedAt: happenedAt), at: .now)
        } else {
            RecordedEvent(happenedAt: happenedAt, payload: .medication(medication))
        }
        do {
            try await store.save(event)
            await refresh(after: event.happenedAt)
            return true
        } catch {
            failure = String(describing: error)
            return false
        }
    }

    func delete(_ event: RecordedEvent) async {
        do {
            try await store.delete(event.id, at: .now)
            lastDeleted = event
            await load()
            scheduleUndoExpiry(for: event.id)
        } catch {
            failure = String(describing: error)
        }
    }

    func undoDelete() async {
        guard let deleted = lastDeleted else { return }
        do {
            try await store.restore(deleted.id)
            lastDeleted = nil
            await load()
        } catch {
            failure = String(describing: error)
        }
    }

    private func scheduleUndoExpiry(for id: UUID) {
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(5))
            guard let self, lastDeleted?.id == id else { return }
            lastDeleted = nil
        }
    }
}
