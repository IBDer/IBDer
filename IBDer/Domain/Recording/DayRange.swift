import Foundation

/// One local day, as a half-open interval a record must fall inside.
///
/// A day starts at local midnight: 23:59 and 00:01 are two different days, and daylight-saving days
/// are handled by the calendar rather than by adding 86 400 seconds.
struct DayRange: Equatable, Hashable, Sendable {
    let start: Date
    /// Exclusive.
    let end: Date

    static func containing(_ date: Date, calendar: Calendar = .current) -> DayRange {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86400)
        return DayRange(start: start, end: end)
    }

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}
