import Foundation

/// One of the four periods M1 offers. Boundaries are calendar boundaries, not rolling windows.
enum TrendRange: String, CaseIterable, Sendable, Identifiable {
    case week
    case month
    case sixMonths
    case year

    var id: String {
        rawValue
    }

    var isDaily: Bool {
        switch self {
        case .week, .month: true
        case .sixMonths, .year: false
        }
    }
}

/// One column of the chart: a calendar bucket with its recorded value.
struct TrendBucket: Identifiable, Sendable, Equatable {
    let start: Date
    let end: Date
    /// Nil means nothing was recorded in this bucket. That is not a zero.
    let value: Int?
    /// How many days inside the bucket carry at least one record.
    let recordedDays: Int
    let totalDays: Int

    var id: Date {
        start
    }
}

/// What the chart counts. Facts only: no score, no verdict.
enum TrendMetric: String, CaseIterable, Sendable, Identifiable {
    case bowelMovements
    case meals
    case supplements
    case medications

    var id: String {
        rawValue
    }

    func count(in events: [RecordedEvent]) -> Int {
        switch self {
        case .bowelMovements:
            DayTotals.bowelMovements(in: events)
        case .meals:
            events.count { event in
                if case let .meal(meal) = event.payload {
                    meal.kind == .meal
                } else {
                    false
                }
            }
        case .supplements:
            events.count { event in
                if case let .meal(meal) = event.payload {
                    meal.kind == .supplement
                } else {
                    false
                }
            }
        case .medications:
            events.count { event in
                if case .medication = event.payload {
                    true
                } else {
                    false
                }
            }
        }
    }
}

/// Turning records into buckets. Pure, so the counting rules can be tested without a screen.
enum TrendAggregation {
    /// The period containing the date, as a half-open interval.
    static func period(
        for range: TrendRange,
        containing date: Date,
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        switch range {
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            return (start, calendar.date(byAdding: .day, value: 7, to: start) ?? start)
        case .month:
            let start = calendar.dateInterval(of: .month, for: date)?.start ?? date
            return (start, calendar.date(byAdding: .month, value: 1, to: start) ?? start)
        case .sixMonths:
            let start = calendar.dateInterval(of: .month, for: date)?.start ?? date
            return (start, calendar.date(byAdding: .month, value: 6, to: start) ?? start)
        case .year:
            let start = calendar.dateInterval(of: .year, for: date)?.start ?? date
            return (start, calendar.date(byAdding: .year, value: 1, to: start) ?? start)
        }
    }

    static func buckets(
        for range: TrendRange,
        containing date: Date,
        events: [RecordedEvent],
        metric: TrendMetric,
        calendar: Calendar = .current
    ) -> [TrendBucket] {
        let period = period(for: range, containing: date, calendar: calendar)
        var buckets: [TrendBucket] = []
        var cursor = period.start

        while cursor < period.end {
            let step: Calendar.Component = range.isDaily ? .day : (range == .sixMonths ? .day : .month)
            let stepCount = range == .sixMonths ? 7 : 1
            let proposed = calendar.date(byAdding: step, value: stepCount, to: cursor) ?? period.end
            let end = min(proposed, period.end)

            let inside = events.filter { event in
                !event.isDeleted && event.happenedAt >= cursor && event.happenedAt < end
            }
            let totalDays = calendar.dateComponents([.day], from: cursor, to: end).day ?? 1
            let recorded = Set(inside.map { event in calendar.startOfDay(for: event.happenedAt) }).count

            buckets.append(
                TrendBucket(
                    start: cursor,
                    end: end,
                    value: inside.isEmpty ? nil : metric.count(in: inside),
                    recordedDays: recorded,
                    totalDays: totalDays
                )
            )
            cursor = end
        }
        return buckets
    }

    /// Days in the period with no record at all.
    static func unrecordedDays(in buckets: [TrendBucket]) -> Int {
        buckets.reduce(0) { total, bucket in
            total + bucket.totalDays - bucket.recordedDays
        }
    }
}
