import SwiftUI

/// Synthetic sample data. Never a real patient record (AGENTS.md §4) — this exists so the
/// screen can be reviewed before persistence lands, and it is replaced by the real store in
/// tasks 3.x.
struct RecordedEvent: Identifiable {
    enum Kind {
        case toilet, meal, medication, infusion

        var symbol: String {
            switch self {
            case .toilet: "drop.fill"
            case .meal: "fork.knife"
            case .medication: "pills.fill"
            case .infusion: "syringe.fill"
            }
        }
    }

    let id = UUID()
    let kind: Kind
    let timeText: String
    /// A record the patient filled in only partly — shown, never counted as complete.
    let isPartial: Bool

    var symbol: String { kind.symbol }

    var titleKey: LocalizedStringKey {
        switch kind {
        case .toilet: "entry.toilet"
        case .meal: "entry.meal"
        case .medication: "entry.medication"
        case .infusion: "entry.infusion"
        }
    }

    /// Screenshots and UI tests need both states from one build:
    /// launch with `-emptyDay` to see the empty day.
    static var launchSample: [RecordedEvent] {
        ProcessInfo.processInfo.arguments.contains("-emptyDay") ? [] : sample
    }

    static let sample: [RecordedEvent] = [
        RecordedEvent(kind: .toilet, timeText: "07:20", isPartial: false),
        RecordedEvent(kind: .medication, timeText: "08:00", isPartial: false),
        RecordedEvent(kind: .meal, timeText: "08:15", isPartial: true),
        RecordedEvent(kind: .toilet, timeText: "13:40", isPartial: false),
    ]
}
