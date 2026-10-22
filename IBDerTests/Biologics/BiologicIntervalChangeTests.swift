import Foundation
@testable import IBDer
import Testing

/// Changing the repeating interval: it starts from the chosen dose, keeps the earlier ones, and
/// records why.
struct BiologicIntervalChangeTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2027, month: month, day: day, hour: 9))
            ?? Date(timeIntervalSince1970: 0)
    }

    private func makeModel() async throws -> BiologicModel {
        let model = await BiologicModel(store: InMemoryBiologicStore())
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(3, 1), weightKilograms: 60)
        return model
    }

    @Test func aChangeStartsAtTheChosenDoseAndKeepsEarlierOnes() async throws {
        let model = try await makeModel()
        let doses = await model.state.doses.sorted { $0.date < $1.date }
        let chosen = try #require(doses.dropFirst(4).first)
        let earlier = doses.prefix(4).map(\.date)

        _ = await model.changeInterval(toWeeks: 10, from: chosen, reason: "review")
        let after = await model.state.doses.sorted { $0.date < $1.date }

        #expect(after.prefix(4).map(\.date) == earlier, "doses before the chosen one keep their dates")
        #expect(after[4].date == chosen.date)
        #expect(after[5].date == calendar.date(byAdding: .weekOfYear, value: 10, to: chosen.date))
    }

    @Test func theReasonAndTheNewIntervalAreKept() async throws {
        let model = try await makeModel()
        let chosen = try #require(await model.nextDose)
        _ = await model.changeInterval(toWeeks: 12, from: chosen, reason: "lost response")

        #expect(await model.plan?.intervalWeeks == 12)
        #expect(await model.plan?.intervalChanges.last?.reason == "lost response")
        #expect(await model.plan?.intervalChanges.last?.weeks == 12)
    }

    @Test func remindersFollowTheNewDates() async throws {
        let scheduler = InMemoryNotificationScheduler()
        let model = await BiologicModel(store: InMemoryBiologicStore(), notifications: scheduler)
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(3, 1), weightKilograms: 60)
        let before = await scheduler.pending()
        let chosen = try #require(await model.nextDose)

        _ = await model.changeInterval(toWeeks: 12, from: chosen, reason: "plan")
        let after = await scheduler.pending()
        #expect(!before.isEmpty)
        #expect(!after.isEmpty)
    }
}
