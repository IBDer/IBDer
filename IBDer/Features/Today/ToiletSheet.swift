import SwiftUI

/// Recording a toilet event: four outcomes first, then the details only a stool needs.
struct ToiletSheet: View {
    let onSave: (ToiletEvent, Date) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var happenedAt: Date
    @State private var outcome: ToiletEvent.Outcome?
    @State private var bristol: BristolType?
    @State private var blood: BloodAmount?
    @State private var perianal: PerianalSensation?
    @State private var detent: PresentationDetent
    @State private var isSaving = false

    init(day: Date, editing: RecordedEvent?, onSave: @escaping (ToiletEvent, Date) async -> Bool) {
        self.onSave = onSave
        let existing = editing?.payload.toiletEvent
        _happenedAt = State(initialValue: editing?.happenedAt ?? Pickers.defaultTime(for: day))
        _outcome = State(initialValue: existing?.outcome)
        _bristol = State(initialValue: existing?.bristol)
        _blood = State(initialValue: existing?.blood)
        _perianal = State(initialValue: existing?.perianal)
        _detent = State(initialValue: existing?.outcome == .stool ? .large : .medium)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "toilet.title")
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    TimeRow(happenedAt: $happenedAt)
                    outcomeGrid
                    if outcome == .stool {
                        ToiletDetails(bristol: $bristol, blood: $blood, perianal: $perianal)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, 88)
            }
            saveBar
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.visible)
        .onChange(of: outcome) { _, newValue in
            withAnimation(.snappy(duration: 0.22)) {
                detent = newValue == .stool ? .large : .medium
            }
        }
    }

    private var outcomeGrid: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.outcome.title")
            ChoiceGrid {
                ForEach(ToiletEvent.Outcome.allCases, id: \.self) { option in
                    ChoiceChip(
                        titleKey: Self.outcomeTitle(option),
                        isSelected: outcome == option,
                        identifier: "toilet.outcome.\(option.rawValue)"
                    ) {
                        outcome = option
                        if option != .stool {
                            bristol = nil
                            blood = nil
                            perianal = nil
                        }
                    }
                }
            }
        }
    }

    private var saveBar: some View {
        PrimaryButton(titleKey: "common.save", isEnabled: outcome != nil && !isSaving) {
            guard let outcome else { return }
            isSaving = true
            let event = ToiletEvent(
                outcome: outcome,
                bristol: outcome == .stool ? bristol : nil,
                blood: outcome == .stool ? blood : nil,
                perianal: outcome == .stool ? perianal : nil
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
        .background(DesignTokens.Color.background)
    }

    private static func outcomeTitle(_ outcome: ToiletEvent.Outcome) -> LocalizedStringKey {
        switch outcome {
        case .stool: "toilet.outcome.stool"
        case .bloodOrMucusOnly: "toilet.outcome.bloodOrMucusOnly"
        case .urgeOnly: "toilet.outcome.urgeOnly"
        case .uncertain: "toilet.outcome.uncertain"
        }
    }
}
