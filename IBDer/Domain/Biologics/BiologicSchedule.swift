import Foundation

/// Pure rules about dates: which doses a regimen produces, which one is next, how late it is, and
/// when to remind the patient. No screen and no store is involved.
enum BiologicSchedule {
    /// How many maintenance doses to keep ahead of the patient.
    static let maintenanceHorizon = 8

    /// One date in a regimen, before it becomes a dose in a plan.
    struct ScheduledDose: Sendable, Equatable {
        let week: Int
        let amount: BiologicRegimen.Amount
        let route: BiologicRegimen.Route
    }

    static func schedule(for regimen: BiologicRegimen) -> [ScheduledDose] {
        var entries = regimen.starterDoses.map {
            ScheduledDose(week: $0.week, amount: $0.amount, route: $0.route)
        }
        var week = regimen.maintenanceFromWeek
        for _ in 0 ..< maintenanceHorizon {
            entries.append(
                ScheduledDose(week: week, amount: regimen.maintenanceAmount, route: regimen.maintenanceRoute)
            )
            week += regimen.maintenanceIntervalWeeks
        }
        return entries.sorted { $0.week < $1.week }
    }

    static func doses(
        for plan: BiologicPlan,
        regimen: BiologicRegimen,
        calendar: Calendar = .current
    ) -> [PlannedDose] {
        schedule(for: regimen).map { entry in
            PlannedDose(
                planID: plan.id,
                date: calendar.date(byAdding: .day, value: entry.week * 7, to: plan.startedAt) ?? plan.startedAt,
                amountMilligrams: entry.amount.milligrams(forWeight: plan.weightKilograms),
                route: entry.route,
                checklist: entry.route == .intravenous ? ChecklistItem.defaults : []
            )
        }
    }

    /// The next dose that is still expected, earliest first.
    static func nextDose(in doses: [PlannedDose]) -> PlannedDose? {
        doses
            .filter { $0.status == .planned }
            .min { $0.date < $1.date }
    }

    /// How many whole days an appointment is late. Nil when it is not late.
    static func overdueDays(for dose: PlannedDose, now: Date, calendar: Calendar = .current) -> Int? {
        guard dose.status == .planned, dose.date < now else { return nil }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: dose.date),
            to: calendar.startOfDay(for: now)
        ).day
        guard let days, days > 0 else { return nil }
        return days
    }

    /// Two weeks, one week and one day before, at 09:00 local time.
    static func reminderDates(
        for dose: PlannedDose,
        leadTimes: Set<Int> = [14, 7, 1],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Date] {
        let dates: [Date] = leadTimes.compactMap { offset -> Date? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: dose.date),
                  let atNine = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day),
                  atNine > now
            else { return nil }
            return atNine
        }
        return dates.sorted()
    }

    /// The number of days until a dose. Negative when it is late.
    static func daysUntil(_ dose: PlannedDose, from now: Date, calendar: Calendar = .current) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: dose.date))
            .day ?? 0
    }
}
