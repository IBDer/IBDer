import Foundation
@testable import IBDer
import Testing

/// Cancelling one appointment: it leaves the plan alone, takes its reminders with it, and never
/// writes a dose.
struct BiologicCancellationTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2027, month: month, day: day, hour: 9))
            ?? Date(timeIntervalSince1970: 0)
    }

    private func makeModel() async throws -> (BiologicModel, InMemoryNotificationScheduler) {
        let scheduler = InMemoryNotificationScheduler()
        let model = await BiologicModel(store: InMemoryBiologicStore(), notifications: scheduler)
        let regimen = try #require(BiologicCatalogue.regimen(id: "vedolizumab"))
        _ = await model.startPlan(regimen: regimen, startingAt: date(3, 1), weightKilograms: 60)
        return (model, scheduler)
    }

    @Test func cancellingMovesToTheNextAppointment() async throws {
        let (model, _) = try await makeModel()
        let first = try #require(await model.nextDose)
        let second = try #require(await model.state.doses.sorted { $0.date < $1.date }.dropFirst().first)

        _ = await model.cancel(first, reason: "plan changed")
        #expect(await model.state.doses.first { $0.id == first.id }?.status == .cancelled)
        #expect(await model.nextDose?.id == second.id)
    }

    @Test func cancellingWritesNoDose() async throws {
        let (model, _) = try await makeModel()
        let first = try #require(await model.nextDose)
        _ = await model.cancel(first, reason: "plan changed")
        #expect(await model.state.records.isEmpty)
    }

    @Test func cancellingRemovesItsReminders() async throws {
        let (model, scheduler) = try await makeModel()
        let first = try #require(await model.nextDose)
        let before = await scheduler.pending()
        _ = await model.cancel(first, reason: "plan changed")
        let after = await scheduler.pending()
        #expect(after.count == before.count - 3)
    }

    @Test func theReasonIsKept() async throws {
        let (model, _) = try await makeModel()
        let first = try #require(await model.nextDose)
        _ = await model.cancel(first, reason: "doctor changed it")
        #expect(await model.state.doses.first { $0.id == first.id }?.cancellationReason == "doctor changed it")
    }
}
