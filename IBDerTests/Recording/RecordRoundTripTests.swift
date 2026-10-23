import Foundation
@testable import IBDer
import Testing

/// The checks the issue acceptance asks for: a medication keeps its actual dose, an edit may move a
/// record into another day without losing its history, and a dose is never recorded twice.
struct RecordRoundTripTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))
            ?? Date(timeIntervalSince1970: 0)
    }

    @Test func aPartialDoseKeepsTheActualAmount() async throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "ibder-medication-\(UUID().uuidString)")
            .appending(path: "records.json")
        let event = RecordedEvent(
            happenedAt: date(20, 8),
            payload: .medication(MedicationEvent(name: "mesalazine", dose: .known(250), unit: "mg"))
        )
        try await FileEventStore(fileURL: url).save(event)

        let day = DayRange.containing(date(20, 8), calendar: calendar)
        let loaded = try await FileEventStore(fileURL: url).events(in: day)
        let first = try #require(loaded.first)
        guard case let .medication(medication) = first.payload else {
            Issue.record("the payload came back as something else")
            return
        }
        #expect(medication.dose == .known(250))
        #expect(medication.unit == "mg")
    }

    @Test func anEditCanMoveARecordToAnotherDay() {
        let event = RecordedEvent(
            happenedAt: date(20, 8),
            payload: .meal(MealEvent(kind: .meal))
        )
        let moved = event.applying(.init(happenedAt: date(21, 8)), at: date(22, 9))

        let oldDay = DayRange.containing(date(20, 12), calendar: calendar)
        let newDay = DayRange.containing(date(21, 12), calendar: calendar)
        #expect(!oldDay.contains(moved.happenedAt))
        #expect(newDay.contains(moved.happenedAt))
        #expect(moved.revisions.count == 1, "the previous time is kept")
    }

    @Test func recordingTheSameDoseTwiceDoesNotDuplicateIt() async throws {
        let model = await BiologicModel(store: InMemoryBiologicStore())
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(20, 9), weightKilograms: 60)
        let next = try #require(await model.nextDose)

        let first = await model.record(next, amountMilligrams: 300)
        let second = await model.record(next, amountMilligrams: 300)
        #expect(first)
        #expect(!second, "a second confirmation is not a second dose")
        #expect(await model.state.records.count == 1)
    }
}
