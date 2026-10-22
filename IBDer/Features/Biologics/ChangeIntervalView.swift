import SwiftUI

/// Changing the repeating interval. It starts at one stated dose, keeps the earlier ones, and asks
/// why — because the label's spacing is normally the reason it is what it is.
struct ChangeIntervalView: View {
    let model: BiologicModel
    let onDone: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var weeks: Int
    @State private var fromDoseID: UUID?
    @State private var reason = "review"
    @State private var isSaving = false

    private static let choices = [4, 6, 8, 10, 12, 16]
    private static let reasons = ["review", "response", "sideEffect", "other"]

    init(model: BiologicModel, onDone: @escaping () -> Void) {
        self.model = model
        self.onDone = onDone
        _weeks = State(initialValue: model.plan?.intervalWeeks ?? 8)
        _fromDoseID = State(initialValue: model.nextDose?.id)
    }

    private var upcoming: [PlannedDose] {
        model.state.doses
            .filter { $0.status == .planned }
            .sorted { $0.date < $1.date }
            .prefix(6)
            .map(\.self)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "biologic.interval.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        SectionTitle(titleKey: "biologic.interval.weeks")
                        ChoiceGrid {
                            ForEach(Self.choices, id: \.self) { choice in
                                ChoiceChip(
                                    titleKey: "biologic.interval.weeksValue \(choice)",
                                    isSelected: weeks == choice,
                                    identifier: "interval.weeks.\(choice)"
                                ) {
                                    weeks = choice
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        SectionTitle(titleKey: "biologic.interval.from")
                        ForEach(upcoming) { dose in
                            Button {
                                fromDoseID = dose.id
                            } label: {
                                HStack {
                                    Text(dose.date, format: .dateTime.year().month().day())
                                        .font(DesignTokens.Typography.body)
                                        .foregroundStyle(DesignTokens.Color.textPrimary)
                                    Spacer()
                                    Image(systemName: fromDoseID == dose.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(fromDoseID == dose.id ? DesignTokens.Color
                                            .accent : DesignTokens.Color.textSecondary)
                                }
                                .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("interval.from.\(dose.id)")
                        }
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        SectionTitle(titleKey: "biologic.interval.reason")
                        ChoiceGrid {
                            ForEach(Self.reasons, id: \.self) { item in
                                ChoiceChip(
                                    titleKey: reasonTitle(item),
                                    isSelected: reason == item,
                                    identifier: "interval.reason.\(item)"
                                ) {
                                    reason = item
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: canSave && !isSaving) {
                save()
            }
            .padding(DesignTokens.Spacing.regular)
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var canSave: Bool {
        fromDoseID != nil
    }

    private func save() {
        guard let id = fromDoseID, let dose = model.state.doses.first(where: { $0.id == id }) else { return }
        isSaving = true
        Task {
            let saved = await model.changeInterval(toWeeks: weeks, from: dose, reason: reasonText(reason))
            isSaving = false
            if saved {
                dismiss()
                onDone()
            }
        }
    }

    private func reasonTitle(_ key: String) -> LocalizedStringKey {
        switch key {
        case "response": "biologic.interval.response"
        case "sideEffect": "biologic.interval.sideEffect"
        case "other": "biologic.interval.other"
        default: "biologic.interval.review"
        }
    }

    private func reasonText(_ key: String) -> String {
        switch key {
        case "response": String(localized: "biologic.interval.response")
        case "sideEffect": String(localized: "biologic.interval.sideEffect")
        case "other": String(localized: "biologic.interval.other")
        default: String(localized: "biologic.interval.review")
        }
    }
}
