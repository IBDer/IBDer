import Foundation
@testable import IBDer
import Testing

/// The counting rules behind the chart: a day with no record is unknown, a day with records but no
/// bowel movement is a real zero, and a deleted record leaves both.
struct TrendAggregationTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ month: Int, _ day: Int, _ hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))
            ?? Date(timeIntervalSince1970: 0)
    }

    private func toilet(_ day: Date, outcome: ToiletEvent.Outcome = .stool) -> RecordedEvent {
        RecordedEvent(happenedAt: day, payload: .toilet(ToiletEvent(outcome: outcome, bristol: nil)))
    }

    @Test func aWeekHasSevenBuckets() {
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(buckets.count == 7)
    }

    @Test func aYearHasTwelveBuckets() {
        let buckets = TrendAggregation.buckets(
            for: .year,
            containing: date(10, 21),
            events: [],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(buckets.count == 12)
    }

    @Test func aDayWithoutRecordsIsUnknownNotZero() {
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(buckets.allSatisfy { $0.value == nil })
    }

    @Test func aDayWithRecordsButNoBowelMovementIsARealZero() {
        let meal = RecordedEvent(happenedAt: date(10, 21), payload: .meal(MealEvent(kind: .meal)))
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [meal],
            metric: .bowelMovements,
            calendar: calendar
        )
        let day = buckets.first { $0.start == calendar.startOfDay(for: date(10, 21)) }
        #expect(day?.value == 0)
    }

    @Test func urgeOnlyIsNotCounted() {
        let urge = toilet(date(10, 21), outcome: .urgeOnly)
        let stool = toilet(date(10, 21))
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [urge, stool],
            metric: .bowelMovements,
            calendar: calendar
        )
        let day = buckets.first { $0.start == calendar.startOfDay(for: date(10, 21)) }
        #expect(day?.value == 1)
    }

    @Test func aDeletedRecordLeavesTheBucket() {
        var event = toilet(date(10, 21))
        event.deletedAt = date(10, 21, 12)
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [event],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(buckets.allSatisfy { $0.value == nil })
    }

    @Test func unrecordedDaysAreCountedFromCoverage() {
        let meal = RecordedEvent(happenedAt: date(10, 21), payload: .meal(MealEvent(kind: .meal)))
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [meal],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(TrendAggregation.unrecordedDays(in: buckets) == 6)
    }

    @Test func aRecordOutOfThePeriodIsNotCounted() {
        let outside = toilet(date(9, 1))
        let buckets = TrendAggregation.buckets(
            for: .week,
            containing: date(10, 21),
            events: [outside],
            metric: .bowelMovements,
            calendar: calendar
        )
        #expect(buckets.allSatisfy { $0.value == nil })
    }
}
