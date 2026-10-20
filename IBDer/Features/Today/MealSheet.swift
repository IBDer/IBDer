import SwiftUI

/// What was eaten: a meal, a snack, or a nutritional powder. No analysis, no photo in M1.
struct MealSheet: View {
    let onSave: (MealEvent, Date) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var happenedAt: Date
    @State private var kind: MealEvent.Kind
    @State private var scoops: Int
    @State private var note: String
    @State private var isSaving = false
    @State private var detent: PresentationDetent

    init(day: Date, editing: RecordedEvent?, onSave: @escaping (MealEvent, Date) async -> Bool) {
        self.onSave = onSave
        let existing: MealEvent? = if case let .meal(meal) = editing?.payload {
            meal
        } else {
            nil
        }
        _happenedAt = State(initialValue: editing?.happenedAt ?? Pickers.defaultTime(for: day))
        _kind = State(initialValue: existing?.kind ?? .meal)
        _scoops = State(initialValue: existing?.scoops ?? 6)
        _note = State(initialValue: existing?.note ?? "")
        _detent = State(initialValue: existing?.kind == .supplement ? .large : .medium)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "meal.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    TimeRow(happenedAt: $happenedAt)
                    kindRow
                    if kind == .supplement {
                        scoopsRow
                    }
                    NoteField(note: $note, placeholder: "meal.note.placeholder")
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            PrimaryButton(titleKey: "common.save", isEnabled: !isSaving) {
                isSaving = true
                let event = MealEvent(
                    kind: kind,
                    scoops: kind == .supplement ? scoops : nil,
                    note: note
                )
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
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.visible)
        .onChange(of: kind) { _, newValue in
            withAnimation(.snappy(duration: 0.22)) {
                detent = newValue == .supplement ? .large : .medium
            }
        }
    }

    private var kindRow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "meal.kind.title")
            HStack(spacing: DesignTokens.Spacing.small) {
                ChoiceChip(
                    titleKey: "meal.kind.meal",
                    isSelected: kind == .meal,
                    identifier: "meal.kind.meal"
                ) { kind = .meal }
                ChoiceChip(
                    titleKey: "meal.kind.snack",
                    isSelected: kind == .snack,
                    identifier: "meal.kind.snack"
                ) { kind = .snack }
                ChoiceChip(
                    titleKey: "meal.kind.supplement",
                    isSelected: kind == .supplement,
                    identifier: "meal.kind.supplement"
                ) { kind = .supplement }
            }
        }
    }

    private var scoopsRow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Text("meal.scoops.title")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                Spacer()
                Stepper(value: $scoops, in: 1 ... 12) {
                    HStack(spacing: DesignTokens.Spacing.xSmall) {
                        Text(verbatim: "\(scoops)")
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Text("meal.scoops.unit")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                }
                .labelsHidden()
                .accessibilityIdentifier("meal.scoops")
                Text(verbatim: "\(scoops)")
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Text("meal.scoops.unit")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .padding(DesignTokens.Spacing.medium)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control))

            Text("meal.scoops.hint")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
    }
}
