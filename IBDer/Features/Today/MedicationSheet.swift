import SwiftUI

/// What was actually taken. The product records the fact and never judges adherence.
struct MedicationSheet: View {
    let onSave: (MedicationEvent, Date) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var happenedAt: Date
    @State private var name: String
    @State private var doseText: String
    @State private var unit: String
    @State private var isSaving = false

    init(day: Date, editing: RecordedEvent?, onSave: @escaping (MedicationEvent, Date) async -> Bool) {
        self.onSave = onSave
        let existing: MedicationEvent? = if case let .medication(medication) = editing?.payload {
            medication
        } else {
            nil
        }
        _happenedAt = State(initialValue: editing?.happenedAt ?? Pickers.defaultTime(for: day))
        _name = State(initialValue: existing?.name ?? "")
        _doseText = State(initialValue: existing?.dose.value.map { "\($0.formatted())" } ?? "")
        _unit = State(initialValue: existing?.unit ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "medication.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    TimeRow(happenedAt: $happenedAt)
                    FieldRow(placeholder: "medication.name.placeholder", text: $name)
                    HStack(spacing: DesignTokens.Spacing.small) {
                        FieldRow(placeholder: "medication.dose.placeholder", text: $doseText)
                            .keyboardType(.decimalPad)
                        FieldRow(placeholder: "medication.unit.placeholder", text: $unit)
                            .frame(width: 96)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, DesignTokens.Spacing.large)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: !name.isEmpty && !isSaving) {
                isSaving = true
                let dose = Double(doseText).map { Reading<Double>.known($0) } ?? .unknown
                let event = MedicationEvent(name: name, dose: dose, unit: unit)
                Task {
                    let saved = await onSave(event, happenedAt)
                    isSaving = false
                    if saved {
                        dismiss()
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
