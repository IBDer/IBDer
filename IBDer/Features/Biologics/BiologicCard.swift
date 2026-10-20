import SwiftUI

/// The small biologic card on the day screen: the product and when the next dose is due.
struct BiologicCard: View {
    let model: BiologicModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: "syringe.fill")
                    .font(.footnote)
                    .foregroundStyle(isOverdue ? DesignTokens.Color.alert : DesignTokens.Color.accent)
                Text(title)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                    .lineLimit(1)
                Text(verbatim: "·")
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                subtitle
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(isOverdue ? DesignTokens.Color.alert : DesignTokens.Color.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("biologic.card")
    }

    private var isOverdue: Bool {
        guard let dose = model.nextDose else { return false }
        return BiologicSchedule.overdueDays(for: dose, now: .now) != nil
    }

    private var title: LocalizedStringKey {
        guard let plan = model.plan else { return "biologic.card.setUp" }
        if let custom = plan.customName, !custom.isEmpty {
            return LocalizedStringKey(custom)
        }
        return LocalizedStringKey(BiologicCatalogue.regimen(id: plan.drugID)?.nameKey ?? plan.drugID)
    }

    private var subtitle: Text {
        guard let dose = model.nextDose else { return Text("biologic.card.noNextDose") }
        let route: Text = dose.route == .intravenous
            ? Text("biologic.route.intravenous")
            : Text("biologic.route.subcutaneous")
        return route + Text(verbatim: " · ") + BiologicText.due(dose)
    }
}

/// "today", "in 3 days", "3 days late" — a fact, not a verdict.
enum BiologicText {
    static func due(_ dose: PlannedDose, now: Date = .now, calendar: Calendar = .current) -> Text {
        if let late = BiologicSchedule.overdueDays(for: dose, now: now, calendar: calendar) {
            return Text("biologic.overdue \(late)")
        }
        let days = BiologicSchedule.daysUntil(dose, from: now, calendar: calendar)
        switch days {
        case 0: return Text("biologic.dueToday")
        case 1: return Text("biologic.dueTomorrow")
        default: return Text("biologic.dueIn \(days)")
        }
    }

    static func amount(_ milligrams: Int?) -> Text {
        guard let milligrams else { return Text("biologic.amount.unknown") }
        return Text(verbatim: "\(milligrams) mg")
    }
}
