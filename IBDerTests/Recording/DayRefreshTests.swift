import Foundation
@testable import IBDer
import Testing

/// A save on the day already on screen must refresh that day: recording a late entry and then an
/// early one used to leave the early one invisible until relaunch.
@MainActor
struct DayRefreshTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 23, hour: hour))
            ?? Date(timeIntervalSince1970: 0)
    }

    @Test func aSecondSaveOnTheVisibleDayAppears() async {
        let model = RecordsModel(store: InMemoryEventStore(), day: date(12))
        await model.load()

        _ = await model.save(toilet: ToiletEvent(outcome: .stool, bristol: .type4), at: date(22), editing: nil)
        _ = await model.save(toilet: ToiletEvent(outcome: .stool, bristol: .type3), at: date(8), editing: nil)

        #expect(model.events.count == 2)
        #expect(model.events.map(\.happenedAt) == [date(8), date(22)])
    }

    @Test func savingOnAnotherDayMovesTheViewAndShowsIt() async {
        let model = RecordsModel(store: InMemoryEventStore(), day: date(12))
        await model.load()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date(12)) ?? date(12)

        _ = await model.save(toilet: ToiletEvent(outcome: .stool, bristol: .type4), at: yesterday, editing: nil)

        #expect(calendar.isDate(model.day, inSameDayAs: yesterday))
        #expect(model.events.count == 1)
    }
}
