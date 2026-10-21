import Foundation

/// A product and the regimen printed in its label.
///
/// Nothing here is advice: the source of every number is recorded in
/// docs/research/biologic-regimens.md, the text is shown as the label's text, and the patient can
/// change any of it before saving.
struct BiologicRegimen: Sendable, Equatable {
    enum Route: String, Codable, Sendable, CaseIterable {
        case intravenous
        case subcutaneous
    }

    /// How an amount is arrived at. A calculation is only ever a suggestion.
    enum Amount: Sendable, Equatable {
        case milligrams(Int)
        case milligramsPerKilogram(Int)
        case weightBand([WeightBand])

        func milligrams(forWeight weight: Double?) -> Int? {
            switch self {
            case let .milligrams(value):
                return value
            case let .milligramsPerKilogram(perKilogram):
                guard let weight else { return nil }
                return Int((Double(perKilogram) * weight).rounded())
            case let .weightBand(bands):
                guard let weight else { return nil }
                for band in bands {
                    guard let limit = band.upToKilograms else { return band.milligrams }
                    if weight <= limit {
                        return band.milligrams
                    }
                }
                return bands.last?.milligrams
            }
        }
    }

    struct StarterDose: Sendable, Equatable {
        let week: Int
        let amount: Amount
        let route: Route
    }

    /// Catalogue identity; also the String Catalog key for the product name.
    let id: String
    let starterDoses: [StarterDose]
    /// Week of the first maintenance dose, counted from the first starter dose.
    let maintenanceFromWeek: Int
    let maintenanceIntervalWeeks: Int
    let maintenanceAmount: Amount
    let maintenanceRoute: Route
    /// Some labels allow a longer interval when the response is incomplete.
    let alternativeIntervalWeeks: Int?

    var nameKey: String {
        "biologic.name.\(id)"
    }

    var regimenKey: String {
        "biologic.regimen.\(id)"
    }
}

/// One weight band from a label table.
struct WeightBand: Sendable, Equatable {
    /// Upper bound, inclusive. A nil bound catches everything above the previous band.
    let upToKilograms: Double?
    let milligrams: Int
}

enum BiologicCatalogue {
    /// Read from the labels on 2026-10-20; see docs/research/biologic-regimens.md.
    static let all: [BiologicRegimen] = [
        BiologicRegimen(
            id: "infliximab",
            starterDoses: [
                .init(week: 0, amount: .milligramsPerKilogram(5), route: .intravenous),
                .init(week: 2, amount: .milligramsPerKilogram(5), route: .intravenous),
                .init(week: 6, amount: .milligramsPerKilogram(5), route: .intravenous),
            ],
            maintenanceFromWeek: 14,
            maintenanceIntervalWeeks: 8,
            maintenanceAmount: .milligramsPerKilogram(5),
            maintenanceRoute: .intravenous,
            alternativeIntervalWeeks: nil
        ),
        BiologicRegimen(
            id: "vedolizumab",
            starterDoses: [
                .init(week: 0, amount: .milligrams(300), route: .intravenous),
                .init(week: 2, amount: .milligrams(300), route: .intravenous),
                .init(week: 6, amount: .milligrams(300), route: .intravenous),
            ],
            maintenanceFromWeek: 14,
            maintenanceIntervalWeeks: 8,
            maintenanceAmount: .milligrams(300),
            maintenanceRoute: .intravenous,
            alternativeIntervalWeeks: nil
        ),
        BiologicRegimen(
            id: "adalimumab",
            starterDoses: [
                .init(week: 0, amount: .milligrams(160), route: .subcutaneous),
                .init(week: 2, amount: .milligrams(80), route: .subcutaneous),
            ],
            maintenanceFromWeek: 4,
            maintenanceIntervalWeeks: 2,
            maintenanceAmount: .milligrams(40),
            maintenanceRoute: .subcutaneous,
            alternativeIntervalWeeks: nil
        ),
        BiologicRegimen(
            id: "risankizumab",
            starterDoses: [
                .init(week: 0, amount: .milligrams(600), route: .intravenous),
                .init(week: 4, amount: .milligrams(600), route: .intravenous),
                .init(week: 8, amount: .milligrams(600), route: .intravenous),
            ],
            maintenanceFromWeek: 12,
            maintenanceIntervalWeeks: 8,
            maintenanceAmount: .milligrams(180),
            maintenanceRoute: .subcutaneous,
            alternativeIntervalWeeks: nil
        ),
        BiologicRegimen(
            id: "ustekinumab",
            starterDoses: [
                .init(
                    week: 0,
                    amount: .weightBand([
                        .init(upToKilograms: 55, milligrams: 260),
                        .init(upToKilograms: 85, milligrams: 390),
                        .init(upToKilograms: nil, milligrams: 520),
                    ]),
                    route: .intravenous
                ),
            ],
            maintenanceFromWeek: 8,
            maintenanceIntervalWeeks: 12,
            maintenanceAmount: .milligrams(90),
            maintenanceRoute: .subcutaneous,
            alternativeIntervalWeeks: 8
        ),
        BiologicRegimen(
            id: "guselkumab",
            starterDoses: [
                .init(week: 0, amount: .milligrams(200), route: .intravenous),
                .init(week: 4, amount: .milligrams(200), route: .intravenous),
                .init(week: 8, amount: .milligrams(200), route: .intravenous),
            ],
            maintenanceFromWeek: 16,
            maintenanceIntervalWeeks: 8,
            maintenanceAmount: .milligrams(100),
            maintenanceRoute: .subcutaneous,
            alternativeIntervalWeeks: nil
        ),
    ]

    static func regimen(id: String) -> BiologicRegimen? {
        all.first { $0.id == id }
    }
}
