import SwiftUI

/// Choosing the product and starting the plan from the label's regimen.
struct StartPlanView: View {
    let model: BiologicModel
    let profile: ProfileModel
    let onSaved: () -> Void

    @State private var selected = BiologicCatalogue.all[0].id
    @State private var weightText = ""
    @State private var startDate = Date()
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                    Text("biologic.start.title")
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(DesignTokens.Color.textPrimary)
                    Text("biologic.start.explain")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }

                VStack(spacing: DesignTokens.Spacing.small) {
                    ForEach(BiologicCatalogue.all, id: \.id) { regimen in
                        drugRow(regimen)
                    }
                }

                NumberRow(
                    titleKey: "profile.weight",
                    identifier: "biologic.weight",
                    placeholder: "profile.weight.placeholder",
                    unit: "profile.weight.unit",
                    text: $weightText
                )

                DatePicker("biologic.start.date", selection: $startDate, displayedComponents: .date)
                    .font(DesignTokens.Typography.body)

                PrimaryButton(
                    titleKey: "biologic.start.save",
                    isEnabled: !isSaving,
                    identifier: "biologic.start.save"
                ) {
                    save()
                }
            }
            .padding(DesignTokens.Spacing.regular)
        }
        .task {
            if weightText.isEmpty, let weight = profile.profile.weightKilograms {
                weightText = weight.formatted(.number.precision(.fractionLength(0 ... 1)).grouping(.never))
            }
        }
    }

    private func drugRow(_ regimen: BiologicRegimen) -> some View {
        Button {
            selected = regimen.id
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(regimen.nameKey))
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Text(LocalizedStringKey(regimen.regimenKey))
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.medium)
            .background(
                selected == regimen.id ? DesignTokens.Color.accentSoft : DesignTokens.Color.surface,
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                    .stroke(
                        selected == regimen.id ? DesignTokens.Color.accent : DesignTokens.Color.border,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("biologic.drug.\(regimen.id)")
    }

    private func save() {
        guard let regimen = BiologicCatalogue.regimen(id: selected) else { return }
        isSaving = true
        let weight = Double(weightText.replacingOccurrences(of: ",", with: "."))
        // A plan starts on a day, not at the minute the form was filled in.
        let day = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: startDate) ?? startDate
        Task {
            let saved = await model.startPlan(regimen: regimen, startingAt: day, weightKilograms: weight)
            isSaving = false
            if saved {
                onSaved()
            }
        }
    }
}

/// Recording the dose that actually happened. The amount the hospital prepared wins over the suggestion.
struct RecordDoseView: View {
    let model: BiologicModel
    let dose: PlannedDose
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String
    @State private var note = ""
    @State private var isSaving = false

    init(model: BiologicModel, dose: PlannedDose, onSaved: @escaping () -> Void) {
        self.model = model
        self.dose = dose
        self.onSaved = onSaved
        _amountText = State(initialValue: dose.amountMilligrams.map { "\($0)" } ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "biologic.record.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    Text(dose.date, format: .dateTime.year().month().day().hour().minute())
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                    NumberRow(
                        titleKey: "biologic.record.amount",
                        identifier: "biologic.record.amount",
                        placeholder: "biologic.record.amount.placeholder",
                        unit: "biologic.record.unit",
                        text: $amountText
                    )
                    NoteField(note: $note, placeholder: "biologic.record.note")
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: !isSaving) {
                isSaving = true
                let amount = Int(amountText.filter(\.isNumber))
                Task {
                    let saved = await model.record(dose, amountMilligrams: amount, note: note)
                    isSaving = false
                    if saved {
                        dismiss()
                        onSaved()
                    }
                }
            }
            .padding(DesignTokens.Spacing.regular)
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// Moving one appointment. The repeating arrangement is untouched.
struct PostponeView: View {
    let model: BiologicModel
    let dose: PlannedDose
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var date: Date
    @State private var reason = "unwell"
    @State private var isSaving = false

    private static let reasons = ["unwell", "travel", "bloodTest"]

    private static func reasonTitle(_ key: String) -> LocalizedStringKey {
        switch key {
        case "travel": "biologic.postpone.travel"
        case "bloodTest": "biologic.postpone.bloodTest"
        default: "biologic.postpone.unwell"
        }
    }

    private static func reasonText(_ key: String) -> String {
        switch key {
        case "travel": String(localized: "biologic.postpone.travel")
        case "bloodTest": String(localized: "biologic.postpone.bloodTest")
        default: String(localized: "biologic.postpone.unwell")
        }
    }

    init(model: BiologicModel, dose: PlannedDose, onSaved: @escaping () -> Void) {
        self.model = model
        self.dose = dose
        self.onSaved = onSaved
        _date = State(initialValue: dose.date)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "biologic.postpone.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    DatePicker("biologic.postpone.date", selection: $date, displayedComponents: .date)
                        .font(DesignTokens.Typography.body)
                    SectionTitle(titleKey: "biologic.postpone.reason")
                    ChoiceGrid {
                        ForEach(Self.reasons, id: \.self) { item in
                            ChoiceChip(
                                titleKey: Self.reasonTitle(item),
                                isSelected: reason == item,
                                identifier: "postpone.\(item)"
                            ) {
                                reason = item
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: !isSaving) {
                isSaving = true
                Task {
                    let saved = await model.postpone(
                        dose,
                        to: date,
                        reason: Self.reasonText(reason)
                    )
                    isSaving = false
                    if saved {
                        dismiss()
                        onSaved()
                    }
                }
            }
            .padding(DesignTokens.Spacing.regular)
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
