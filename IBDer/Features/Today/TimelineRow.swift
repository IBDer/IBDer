import SwiftUI

/// One fact in the day's timeline: the time on the left, a dot on the line, the fact on the right.
/// No card, no verdict, and no colour that means bad (ADR-0009).
struct TimelineRow: View {
    let event: RecordedEvent
    let isLast: Bool

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.medium) {
            Text(Self.timeFormatter.string(from: event.happenedAt))
                .font(DesignTokens.Typography.caption.monospacedDigit())
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .frame(width: 42, alignment: .trailing)
                .padding(.top, 3)

            VStack(spacing: 0) {
                Circle()
                    .fill(DesignTokens.Color.accent)
                    .frame(width: 7, height: 7)
                    .padding(.top, 7)
                if !isLast {
                    Rectangle()
                        .fill(DesignTokens.Color.border)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 8)

            VStack(alignment: .leading, spacing: 2) {
                EventSummary.title(of: event)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                if let detail = EventSummary.detail(of: event) {
                    detail
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                if event.isBackfilled() {
                    Text("today.backfilled")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
                if !event.revisions.isEmpty {
                    Text("today.edited")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.small)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("timeline.\(event.kind.rawValue)")
    }
}

/// Turns a record into the words a patient would use. Facts only, never a conclusion.
enum EventSummary {
    static func title(of event: RecordedEvent) -> Text {
        switch event.payload {
        case let .toilet(toilet):
            Text(toiletTitle(toilet.outcome))
        case let .meal(meal):
            Text(mealTitle(meal.kind))
        case let .medication(medication):
            Text(verbatim: medication.name)
        }
    }

    static func detail(of event: RecordedEvent) -> Text? {
        switch event.payload {
        case let .toilet(toilet):
            var parts: [Text] = []
            if let bristol = toilet.bristol {
                parts.append(Text(bristolKey(bristol)))
            }
            if let blood = toilet.blood, blood != .none {
                parts.append(Text(bloodKey(blood)))
            }
            return joined(parts)
        case let .meal(meal):
            guard meal.kind == .supplement, let scoops = meal.scoops else { return nil }
            return Text(verbatim: "\(scoops)") + Text(verbatim: " ") + Text("meal.scoops.unit")
        case let .medication(medication):
            guard let dose = medication.dose.value else { return nil }
            return Text(verbatim: "\(dose.formatted()) \(medication.unit)")
        }
    }

    private static func joined(_ parts: [Text]) -> Text? {
        guard var result = parts.first else { return nil }
        for part in parts.dropFirst() {
            result = result + Text(verbatim: " · ") + part
        }
        return result
    }

    private static func mealTitle(_ kind: MealEvent.Kind) -> LocalizedStringKey {
        switch kind {
        case .meal: "meal.kind.meal"
        case .snack: "meal.kind.snack"
        case .supplement: "meal.kind.supplement"
        }
    }

    private static func toiletTitle(_ outcome: ToiletEvent.Outcome) -> LocalizedStringKey {
        switch outcome {
        case .stool: "toilet.outcome.stool"
        case .bloodOrMucusOnly: "toilet.outcome.bloodOrMucusOnly"
        case .urgeOnly: "toilet.outcome.urgeOnly"
        case .uncertain: "toilet.outcome.uncertain"
        }
    }

    private static func bristolKey(_ type: BristolType) -> LocalizedStringKey {
        switch type {
        case .type1: "toilet.bristol.1"
        case .type2: "toilet.bristol.2"
        case .type3: "toilet.bristol.3"
        case .type4: "toilet.bristol.4"
        case .type5: "toilet.bristol.5"
        case .type6: "toilet.bristol.6"
        case .type7: "toilet.bristol.7"
        }
    }

    private static func bloodKey(_ amount: BloodAmount) -> LocalizedStringKey {
        switch amount {
        case .none: "toilet.blood.none"
        case .onPaper: "toilet.blood.onPaper"
        case .mixed: "toilet.blood.mixed"
        case .mostlyBlood: "toilet.blood.mostlyBlood"
        }
    }
}
