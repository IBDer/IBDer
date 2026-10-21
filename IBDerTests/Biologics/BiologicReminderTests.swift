import Foundation
@testable import IBDer
import Testing

/// Reminders must follow the plan: one per lead time, replaced when the date moves, gone when the
/// dose is recorded, and never created by a notification alone.
struct BiologicReminderTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, _ hour: Int = 9) -> Date {
        calendar
            .date(from: DateComponents(year: 2027, month: 3, day: day, hour: hour)) ?? Date(timeIntervalSince1970: 0)
    }

    private func makeModel() async throws -> (BiologicModel, InMemoryNotificationScheduler) {
        let scheduler = InMemoryNotificationScheduler()
        let model = await BiologicModel(store: InMemoryBiologicStore(), notifications: scheduler)
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(1), weightKilograms: 60)
        return (model, scheduler)
    }

    @Test func startingAPlanAsksForPermissionOnce() async throws {
        let (_, scheduler) = try await makeModel()
        #expect(await scheduler.authorizationRequests == 1)
    }

    @Test func everyPlannedDoseGetsThreeReminders() async throws {
        let (model, scheduler) = try await makeModel()
        let planned = await model.state.doses.filter { $0.status == .planned }.count
        #expect(await scheduler.pending().count == planned * 3)
    }

    @Test func turningOffALeadTimeRemovesOnlyThoseReminders() async throws {
        let (model, scheduler) = try await makeModel()
        let before = await scheduler.pending().count
        _ = await model.toggleLeadTime(7)
        let after = await scheduler.pending().count
        #expect(after == before - (before / 3))
    }

    @Test func recordingTheNextDoseRemovesItsReminders() async throws {
        let (model, scheduler) = try await makeModel()
        let next = try #require(await model.nextDose)
        let before = await scheduler.pending().count
        _ = await model.record(next, amountMilligrams: 300)
        #expect(await scheduler.pending().count == before - 3)
    }

    @Test func movingOneDoseMovesItsReminders() async throws {
        let (model, scheduler) = try await makeModel()
        let next = try #require(await model.nextDose)
        let before = await scheduler.pending()
        _ = await model.postpone(next, to: date(28), reason: "travel")
        let after = await scheduler.pending()
        #expect(after.count == before.count)
        #expect(after.map(\.identifier) != before.map(\.identifier))
    }

    @Test func aRefusedPermissionKeepsThePlan() async throws {
        let scheduler = InMemoryNotificationScheduler(isAuthorized: false)
        let model = await BiologicModel(store: InMemoryBiologicStore(), notifications: scheduler)
        let regimen = try #require(BiologicCatalogue.regimen(id: "adalimumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(1), weightKilograms: 60)
        #expect(await model.remindersAllowed == false)
        #expect(await model.plan != nil)
    }
}
