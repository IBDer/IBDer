import SwiftUI

/// Calling one appointment off. It never writes a dose, and it leaves the plan alone.
struct CancelAppointmentView: View {
    let model: BiologicModel
    let onDone: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var reason = "doctor"
    @State private var isSaving = false

    private static let reasons = ["doctor", "skip", "other"]

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "biologic.cancel.title", closeKey: "common.close")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    if let dose = model.nextDose {
                        Text(dose.date, format: .dateTime.year().month().day())
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                    SectionTitle(titleKey: "biologic.cancel.reason")
                    ChoiceGrid {
                        ForEach(Self.reasons, id: \.self) { item in
                            ChoiceChip(
                                titleKey: Self.title(item),
                                isSelected: reason == item,
                                identifier: "cancel.\(item)"
                            ) {
                                reason = item
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            PrimaryButton(titleKey: "biologic.cancel.confirm", isEnabled: !isSaving) {
                save()
            }
            .padding(DesignTokens.Spacing.regular)
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func save() {
        guard let dose = model.nextDose else { return }
        isSaving = true
        Task {
            let saved = await model.cancel(dose, reason: Self.text(reason))
            isSaving = false
            if saved {
                dismiss()
                onDone()
            }
        }
    }

    private static func title(_ key: String) -> LocalizedStringKey {
        switch key {
        case "skip": "biologic.cancel.skip"
        case "other": "biologic.cancel.other"
        default: "biologic.cancel.doctor"
        }
    }

    private static func text(_ key: String) -> String {
        switch key {
        case "skip": String(localized: "biologic.cancel.skip")
        case "other": String(localized: "biologic.cancel.other")
        default: String(localized: "biologic.cancel.doctor")
        }
    }
}
