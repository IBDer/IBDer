import Foundation
import Observation

/// The biologic plan as the screens see it. The rules live in `BiologicSchedule`; this type only
/// keeps the state and writes it.
@MainActor
@Observable
final class BiologicModel {
    private let store: any BiologicStoring
    private let notifications: any NotificationScheduling
    private(set) var state: BiologicState
    var failure: String?
    /// False when the patient refused notifications. The plan still works.
    private(set) var remindersAllowed = true

    init(
        store: any BiologicStoring,
        notifications: any NotificationScheduling = InMemoryNotificationScheduler(),
        state: BiologicState = BiologicState()
    ) {
        self.store = store
        self.notifications = notifications
        self.state = state
    }

    static func live() -> BiologicModel {
        if ProcessInfo.processInfo.arguments.contains("-inMemory") {
            return BiologicModel(store: InMemoryBiologicStore())
        }
        let scheduler = SystemNotificationScheduler()
        if let store = try? FileBiologicStore.appStore() {
            return BiologicModel(store: store, notifications: scheduler)
        }
        return BiologicModel(store: InMemoryBiologicStore(), notifications: scheduler)
    }

    var plan: BiologicPlan? {
        state.plan
    }

    var nextDose: PlannedDose? {
        BiologicSchedule.nextDose(in: state.doses)
    }

    var regimen: BiologicRegimen? {
        state.plan.flatMap { BiologicCatalogue.regimen(id: $0.drugID) }
    }

    var displayNameKey: String? {
        guard let plan = state.plan else { return nil }
        if let custom = plan.customName, !custom.isEmpty {
            return nil
        }
        return BiologicCatalogue.regimen(id: plan.drugID)?.nameKey
    }

    func load() async {
        do {
            state = try await store.load()
            await reconcileReminders()
        } catch {
            failure = String(describing: error)
        }
    }

    @discardableResult
    func toggleLeadTime(_ days: Int) async -> Bool {
        var next = state
        if next.reminderLeadTimes.contains(days) {
            next.reminderLeadTimes.remove(days)
        } else {
            next.reminderLeadTimes.insert(days)
        }
        return await commit(next)
    }

    @discardableResult
    func startPlan(regimen: BiologicRegimen, startingAt date: Date, weightKilograms: Double?) async -> Bool {
        let plan = BiologicPlan(
            drugID: regimen.id,
            intervalWeeks: regimen.maintenanceIntervalWeeks,
            startedAt: date,
            weightKilograms: weightKilograms
        )
        let doses = BiologicSchedule.doses(for: plan, regimen: regimen)
        let saved = await commit(
            BiologicState(
                plan: plan,
                doses: doses,
                records: state.records,
                reminderLeadTimes: state.reminderLeadTimes
            )
        )
        if saved {
            remindersAllowed = await notifications.requestAuthorization()
            await reconcileReminders()
        }
        return saved
    }

    /// Records a dose that actually happened and marks the planned dose as taken.
    @discardableResult
    func record(_ dose: PlannedDose, amountMilligrams: Int?, note: String = "") async -> Bool {
        guard let index = state.doses.firstIndex(where: { $0.id == dose.id }),
              state.doses[index].status == .planned
        else { return false }

        var next = state
        next.doses[index].status = .taken
        next.records.append(
            InfusionRecord(
                planID: dose.planID,
                plannedDoseID: dose.id,
                date: dose.date,
                amountMilligrams: amountMilligrams,
                route: dose.route,
                note: note
            )
        )
        return await commit(next)
    }

    /// Calls one appointment off. It leaves the plan and the other appointments alone, and it never
    /// writes a dose.
    @discardableResult
    func cancel(_ dose: PlannedDose, reason: String) async -> Bool {
        guard let index = state.doses.firstIndex(where: { $0.id == dose.id }),
              state.doses[index].status == .planned
        else { return false }
        var next = state
        next.doses[index].status = .cancelled
        next.doses[index].cancellationReason = reason
        return await commit(next)
    }

    /// Moves one dose. The repeating arrangement is untouched.
    @discardableResult
    func postpone(_ dose: PlannedDose, to date: Date, reason: String) async -> Bool {
        guard let index = state.doses.firstIndex(where: { $0.id == dose.id }) else { return false }
        var next = state
        next.doses[index].date = date
        next.doses[index].postponementReason = reason
        return await commit(next)
    }

    /// Changes the repeating interval from one stated dose onward. Earlier doses keep their dates.
    @discardableResult
    func changeInterval(toWeeks weeks: Int, from dose: PlannedDose, reason: String) async -> Bool {
        guard var plan = state.plan,
              let regimen = BiologicCatalogue.regimen(id: plan.drugID),
              let startIndex = state.doses.firstIndex(where: { $0.id == dose.id })
        else { return false }

        plan.intervalWeeks = weeks
        plan.intervalChanges.append(
            IntervalChange(
                changedAt: .now,
                weeks: weeks,
                fromDoseDate: dose.date,
                reason: reason
            )
        )

        var doses = Array(state.doses.prefix(startIndex))
        var date = dose.date
        for _ in 0 ..< BiologicSchedule.maintenanceHorizon {
            doses.append(
                PlannedDose(
                    planID: plan.id,
                    date: date,
                    amountMilligrams: regimen.maintenanceAmount.milligrams(forWeight: plan.weightKilograms),
                    route: regimen.maintenanceRoute,
                    checklist: regimen.maintenanceRoute == .intravenous ? ChecklistItem.defaults : []
                )
            )
            date = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: date) ?? date
        }

        return await commit(
            BiologicState(
                plan: plan,
                doses: doses,
                records: state.records,
                reminderLeadTimes: state.reminderLeadTimes
            )
        )
    }

    @discardableResult
    func toggleChecklist(item: ChecklistItem, in dose: PlannedDose) async -> Bool {
        guard let doseIndex = state.doses.firstIndex(where: { $0.id == dose.id }),
              let itemIndex = state.doses[doseIndex].checklist.firstIndex(where: { $0.id == item.id })
        else { return false }
        var next = state
        next.doses[doseIndex].checklist[itemIndex].isDone.toggle()
        return await commit(next)
    }

    @discardableResult
    private func commit(_ next: BiologicState) async -> Bool {
        do {
            try await store.save(next)
            state = next
            await reconcileReminders()
            return true
        } catch {
            failure = String(describing: error)
            return false
        }
    }

    /// Replaces every biologic reminder with the ones the current state implies. Idempotent, so it
    /// runs after every change and on launch: a reschedule or a cancellation removes the old ones.
    private func reconcileReminders() async {
        guard let plan = state.plan else {
            await notifications.replaceAll(prefix: "biologic.", with: [])
            return
        }
        let name = displayName(for: plan)
        let requests = state.doses
            .filter { $0.status == .planned }
            .flatMap { dose in
                BiologicSchedule.reminderDates(for: dose, leadTimes: state.reminderLeadTimes)
                    .map { date in
                        ReminderRequest(
                            identifier: "biologic.\(dose.id.uuidString).\(Int(date.timeIntervalSince1970))",
                            date: date,
                            title: String(localized: "biologic.reminder.title"),
                            body: "\(name) · \(date.formatted(date: .abbreviated, time: .omitted))"
                        )
                    }
            }
        await notifications.replaceAll(prefix: "biologic.", with: requests)
    }

    private func displayName(for plan: BiologicPlan) -> String {
        if let custom = plan.customName, !custom.isEmpty {
            return custom
        }
        guard let key = BiologicCatalogue.regimen(id: plan.drugID)?.nameKey else { return plan.drugID }
        return String(localized: String.LocalizationValue(key))
    }
}
