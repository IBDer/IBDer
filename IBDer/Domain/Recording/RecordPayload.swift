import Foundation

/// What a daily record actually says. Value types with stable coding keys, so a stored record
/// survives a field being added later (docs/adr/0015-record-storage-engine.md).
enum RecordPayload: Sendable, Equatable, Codable {
    case toilet(ToiletEvent)
    case meal(MealEvent)
    case medication(MedicationEvent)

    var kind: RecordKind {
        switch self {
        case .toilet: .toilet
        case .meal: .meal
        case .medication: .medication
        }
    }

    var toiletEvent: ToiletEvent? {
        if case let .toilet(event) = self {
            event
        } else {
            nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind, toilet, meal, medication
    }

    private enum Kind: String, Codable {
        case toilet, meal, medication
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .toilet(event):
            try container.encode(Kind.toilet, forKey: .kind)
            try container.encode(event, forKey: .toilet)
        case let .meal(event):
            try container.encode(Kind.meal, forKey: .kind)
            try container.encode(event, forKey: .meal)
        case let .medication(event):
            try container.encode(Kind.medication, forKey: .kind)
            try container.encode(event, forKey: .medication)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .toilet: self = try .toilet(container.decode(ToiletEvent.self, forKey: .toilet))
        case .meal: self = try .meal(container.decode(MealEvent.self, forKey: .meal))
        case .medication: self = try .medication(container.decode(MedicationEvent.self, forKey: .medication))
        }
    }
}

enum RecordKind: String, Codable, Sendable, CaseIterable {
    case toilet, meal, medication
}

/// One toilet event. The four outcomes are what the patient can report; only stool counts as a
/// bowel movement. Bristol form, blood and perianal sensation refine a stool record.
struct ToiletEvent: Codable, Sendable, Equatable {
    enum Outcome: String, Codable, Sendable, CaseIterable {
        case stool
        case bloodOrMucusOnly
        case urgeOnly
        case uncertain
    }

    var outcome: Outcome
    /// Only meaningful when the outcome is stool.
    var bristol: BristolType?
    /// Nil means blood was not reported. That is not the same as reporting none.
    var blood: BloodAmount?
    var perianal: PerianalSensation?
    var note: String = ""

    var isBowelMovement: Bool {
        outcome == .stool
    }
}

/// Bristol stool form scale, 1-7. The words live in the String Catalog; the number is the identity.
enum BristolType: Int, Codable, Sendable, CaseIterable {
    case type1 = 1, type2, type3, type4, type5, type6, type7
}

enum BloodAmount: String, Codable, Sendable, CaseIterable {
    case none, onPaper, mixed, mostlyBlood
}

enum PerianalSensation: String, Codable, Sendable, CaseIterable {
    case normal, pain, burning, urge, itch
}

/// A meal or snack actually eaten, including an oral nutritional supplement. Photos are not M1.
struct MealEvent: Codable, Sendable, Equatable {
    enum Kind: String, Codable, Sendable, CaseIterable {
        case meal, snack
    }

    var kind: Kind
    var isNutritionalSupplement: Bool = false
    var note: String = ""
}

/// What was actually taken. No adherence field: the product records the fact, never judges it.
struct MedicationEvent: Codable, Sendable, Equatable {
    var name: String
    var dose: Reading<Double> = .unknown
    var unit: String = ""
}
