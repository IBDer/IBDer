import SwiftUI

/// A meal or snack that happened. No nutritional analysis, no photo in M1.
struct MealSheet: View {
    let onSave: (MealEvent, Date) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var happenedAt: Date
    @State private var kind: MealEvent.Kind
    @State private var isSupplement: Bool
    @State private var note: String
    @State private var isSaving = false

    init(day: Date, editing: RecordedEvent?, onSave: @escaping (MealEvent, Date) async -> Bool) {
        self.onSave = onSave
        let existing: MealEvent? = if case let .meal(meal) = editing?.payload {
            meal
        } else {
            nil
        }
        _happenedAt = State(initialValue: editing?.happenedAt ?? Pickers.defaultTime(for: day))
        _kind = State(initialValue: existing?.kind ?? .meal)
        _isSupplement = State(initialValue: existing?.isNutritionalSupplement ?? false)
        _note = State(initialValue: existing?.note ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "meal.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    TimeRow(happenedAt: $happenedAt)
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("meal.kind.title")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                        HStack(spacing: DesignTokens.Spacing.small) {
                            ChoiceChip(titleKey: "meal.kind.meal", isSelected: kind == .meal) { kind = .meal }
                            ChoiceChip(titleKey: "meal.kind.snack", isSelected: kind == .snack) { kind = .snack }
                        }
                    }
                    Toggle("meal.supplement", isOn: $isSupplement)
                        .font(DesignTokens.Typography.body)
                        .tint(DesignTokens.Color.accent)
                        .padding(DesignTokens.Spacing.medium)
                        .background(
                            DesignTokens.Color.surface,
                            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                        )
                    NoteField(note: $note, placeholder: "meal.note.placeholder")
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, DesignTokens.Spacing.large)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: !isSaving) {
                isSaving = true
                let event = MealEvent(kind: kind, isNutritionalSupplement: isSupplement, note: note)
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
