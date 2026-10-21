import Foundation
@testable import IBDer
import Testing

/// The biologic rules: a plan is a sequence of dates from the label, the calculation is only a
/// suggestion, and "late" is a number of days rather than a verdict.
struct BiologicScheduleTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, _ hour: Int = 9) -> Date {
        calendar
            .date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour)) ?? Date(timeIntervalSince1970: 0)
    }

    private func plan(_ id: String, weight: Double? = 60, startingAt start: Date) -> BiologicPlan {
        BiologicPlan(drugID: id, intervalWeeks: 8, startedAt: start, weightKilograms: weight)
    }

    @Test func infliximabStartsAtWeeksZeroTwoSixThenEveryEight() throws {
        let regimen = try #require(BiologicCatalogue.regimen(id: "infliximab"))
        let doses = BiologicSchedule.doses(for: plan("infliximab", startingAt: date(1)), regimen: regimen)

        #expect(doses.count == 3 + BiologicSchedule.maintenanceHorizon)
        #expect(doses[0].date == date(1))
        #expect(doses[1].date == date(15))
        #expect(doses[2].date == date(1 + 42))
        #expect(doses[3].date == date(1 + 98))
        #expect(doses[4].date == date(1 + 154))
    }

    @Test func adalimumabRepeatsEveryTwoWeeks() throws {
        let regimen = try #require(BiologicCatalogue.regimen(id: "adalimumab"))
        let doses = BiologicSchedule.doses(for: plan("adalimumab", weight: 60, startingAt: date(1)), regimen: regimen)

        #expect(doses[0].amountMilligrams == 160)
        #expect(doses[1].date == date(15))
        #expect(doses[1].amountMilligrams == 80)
        #expect(doses[2].date == date(29))
        #expect(doses[2].amountMilligrams == 40)
        #expect(doses[3].date == date(43))
    }

    @Test func aWeightBandedDoseNeedsAWeight() throws {
        let regimen = try #require(BiologicCatalogue.regimen(id: "ustekinumab"))
        let light = BiologicSchedule.doses(for: plan("ustekinumab", weight: 50, startingAt: date(1)), regimen: regimen)
        let middle = BiologicSchedule.doses(for: plan("ustekinumab", weight: 70, startingAt: date(1)), regimen: regimen)
        let heavy = BiologicSchedule.doses(for: plan("ustekinumab", weight: 90, startingAt: date(1)), regimen: regimen)
        let unknown = BiologicSchedule.doses(
            for: plan("ustekinumab", weight: nil, startingAt: date(1)),
            regimen: regimen
        )

        #expect(light[0].amountMilligrams == 260)
        #expect(middle[0].amountMilligrams == 390)
        #expect(heavy[0].amountMilligrams == 520)
        #expect(unknown[0].amountMilligrams == nil, "no weight, no suggestion")
    }

    @Test func aPerKilogramDoseIsCalculatedButNeverGuessed() throws {
        let regimen = try #require(BiologicCatalogue.regimen(id: "infliximab"))
        let sixties = BiologicSchedule.doses(for: plan("infliximab", weight: 60, startingAt: date(1)), regimen: regimen)
        let noWeight = BiologicSchedule.doses(
            for: plan("infliximab", weight: nil, startingAt: date(1)),
            regimen: regimen
        )

        #expect(sixties[0].amountMilligrams == 300)
        #expect(noWeight[0].amountMilligrams == nil)
    }

    @Test func theNextDoseIsTheEarliestOneStillExpected() {
        let planID = UUID()
        let late = PlannedDose(
            planID: planID,
            date: date(1),
            amountMilligrams: 300,
            route: .intravenous,
            status: .taken
        )
        let next = PlannedDose(planID: planID, date: date(15), amountMilligrams: 300, route: .intravenous)
        let later = PlannedDose(planID: planID, date: date(29), amountMilligrams: 300, route: .intravenous)

        #expect(BiologicSchedule.nextDose(in: [later, late, next])?.id == next.id)
    }

    @Test func beingLateIsCountedInDays() {
        let dose = PlannedDose(planID: UUID(), date: date(10), amountMilligrams: 300, route: .intravenous)
        #expect(BiologicSchedule.overdueDays(for: dose, now: date(13)) == 3)
        #expect(BiologicSchedule.overdueDays(for: dose, now: date(9)) == nil)
    }

    @Test func aTakenDoseIsNeverOverdue() {
        let dose = PlannedDose(
            planID: UUID(),
            date: date(10),
            amountMilligrams: 300,
            route: .intravenous,
            status: .taken
        )
        #expect(BiologicSchedule.overdueDays(for: dose, now: date(13)) == nil)
    }

    @Test func remindersAreTwoWeeksAWeekAndADayBefore() {
        let dose = PlannedDose(planID: UUID(), date: date(20), amountMilligrams: 300, route: .intravenous)
        let reminders = BiologicSchedule.reminderDates(for: dose, now: date(1), calendar: calendar)
        #expect(reminders == [date(6), date(13), date(19)])
    }

    @Test func recordingADoseWritesAFactAndLeavesThePlan() async throws {
        let model = await BiologicModel(store: InMemoryBiologicStore())
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(1), weightKilograms: 60)
        let next = try #require(await model.nextDose)

        _ = await model.record(next, amountMilligrams: 300)
        #expect(await model.state.records.count == 1)
        #expect(await model.state.records.first?.plannedDoseID == next.id)
        #expect(await model.state.doses.first?.status == .taken)
    }

    @Test func postponingOneDoseLeavesTheRestAlone() async throws {
        let model = await BiologicModel(store: InMemoryBiologicStore())
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(1), weightKilograms: 60)
        let next = try #require(await model.nextDose)
        let follower = try #require(await model.state.doses.dropFirst().first)

        _ = await model.postpone(next, to: date(20), reason: "unwell")
        #expect(await model.state.doses.first?.date == date(20))
        #expect(await model.state.doses.dropFirst().first?.date == follower.date, "the next one keeps its date")
    }

    @Test func theBiologicStateSurvivesAReopenedFile() async throws {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "ibder-biologic-\(UUID().uuidString)")
            .appending(path: "biologics.json")
        let regimen = try #require(BiologicCatalogue.regimen(id: "infliximab"))
        // A whole second, because the archive keeps ISO-8601 seconds and a `.now` would lose its
        // fraction on the way back.
        let plan = BiologicPlan(
            drugID: regimen.id,
            intervalWeeks: 8,
            startedAt: date(1),
            createdAt: date(1),
            weightKilograms: 60
        )
        let state = BiologicState(plan: plan, doses: BiologicSchedule.doses(for: plan, regimen: regimen))

        try await FileBiologicStore(fileURL: url).save(state)
        let loaded = try await FileBiologicStore(fileURL: url).load()
        #expect(loaded == state)
    }
}
