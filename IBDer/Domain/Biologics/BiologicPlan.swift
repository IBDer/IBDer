import Foundation

/// The arrangement the patient agreed with their care team: which product, how often, from when.
struct BiologicPlan: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    var drugID: String
    /// Used only when the product is not in the catalogue.
    var customName: String?
    var intervalWeeks: Int
    var startedAt: Date
    var createdAt: Date
    var weightKilograms: Double?
    /// Every change to the repeating interval, with the reason it was made for.
    var intervalChanges: [IntervalChange] = []

    init(
        id: UUID = UUID(),
        drugID: String,
        customName: String? = nil,
        intervalWeeks: Int,
        startedAt: Date,
        createdAt: Date = .now,
        weightKilograms: Double? = nil
    ) {
        self.id = id
        self.drugID = drugID
        self.customName = customName
        self.intervalWeeks = intervalWeeks
        self.startedAt = startedAt
        self.createdAt = createdAt
        self.weightKilograms = weightKilograms
    }
}

/// A change to the repeating interval. Applies from one stated dose onward; earlier doses keep
/// the spacing they were given under.
struct IntervalChange: Codable, Sendable, Equatable {
    var changedAt: Date
    var weeks: Int
    var fromDoseDate: Date
    var reason: String
}

/// One dose the patient expects. A pending dose is a plan, never a fact.
struct PlannedDose: Identifiable, Codable, Sendable, Equatable {
    enum Status: String, Codable, Sendable {
        case planned
        case taken
        case cancelled
    }

    let id: UUID
    var planID: UUID
    var date: Date
    var amountMilligrams: Int?
    var route: BiologicRegimen.Route
    var status: Status
    /// Why this one moved, when it did. Never a change to the repeating arrangement.
    var postponementReason: String?
    /// Why this one was called off, when it was. Optional so older archives still decode.
    var cancellationReason: String?
    var checklist: [ChecklistItem]

    init(
        id: UUID = UUID(),
        planID: UUID,
        date: Date,
        amountMilligrams: Int?,
        route: BiologicRegimen.Route,
        status: Status = .planned,
        postponementReason: String? = nil,
        cancellationReason: String? = nil,
        checklist: [ChecklistItem] = []
    ) {
        self.id = id
        self.planID = planID
        self.date = date
        self.amountMilligrams = amountMilligrams
        self.route = route
        self.status = status
        self.postponementReason = postponementReason
        self.cancellationReason = cancellationReason
        self.checklist = checklist
    }
}

/// Something that must happen before an infusion. Unticked is outstanding, not an error.
struct ChecklistItem: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    var key: String
    var isDone: Bool

    init(id: UUID = UUID(), key: String, isDone: Bool = false) {
        self.id = id
        self.key = key
        self.isDone = isDone
    }

    /// The items a new appointment starts with.
    static let defaults: [ChecklistItem] = [
        ChecklistItem(key: "bloodTest"),
        ChecklistItem(key: "timeAndPlace"),
    ]
}

/// A dose that actually happened. The amount is what the hospital prepared.
struct InfusionRecord: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    var planID: UUID?
    var plannedDoseID: UUID?
    var date: Date
    var amountMilligrams: Int?
    var route: BiologicRegimen.Route
    var note: String

    init(
        id: UUID = UUID(),
        planID: UUID? = nil,
        plannedDoseID: UUID? = nil,
        date: Date,
        amountMilligrams: Int?,
        route: BiologicRegimen.Route,
        note: String = ""
    ) {
        self.id = id
        self.planID = planID
        self.plannedDoseID = plannedDoseID
        self.date = date
        self.amountMilligrams = amountMilligrams
        self.route = route
        self.note = note
    }
}
