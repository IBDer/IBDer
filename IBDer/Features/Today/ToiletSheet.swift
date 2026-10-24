import SwiftUI

/// Recording a toilet event in two steps: did anything pass, and only then the details. The old
/// single list mixed a result (stool) with a sensation (urge), so every entry needed translation.
struct ToiletSheet: View {
    let onSave: (ToiletEvent, Date) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var happenedAt: Date
    @State private var outcome: ToiletEvent.Outcome?
    @State private var nothingPassed = false
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
        _nothingPassed = State(initialValue: existing.map { $0.outcome != .stool && $0.outcome != .uncertain } ?? false)
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
                    passedQuestion
                    if nothingPassed {
                        nothingPassedQuestion
                    }
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

    private var passedQuestion: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.passed.title")
            HStack(spacing: DesignTokens.Spacing.small) {
                ChoiceChip(
                    titleKey: "toilet.passed.yes",
                    isSelected: outcome == .stool,
                    identifier: "toilet.passed.yes"
                ) {
                    nothingPassed = false
                    outcome = .stool
                }
                ChoiceChip(
                    titleKey: "toilet.passed.no",
                    isSelected: nothingPassed,
                    identifier: "toilet.passed.no"
                ) {
                    nothingPassed = true
                    outcome = nil
                    bristol = nil
                    blood = nil
                    perianal = nil
                }
                ChoiceChip(
                    titleKey: "toilet.passed.unsure",
                    isSelected: outcome == .uncertain,
                    identifier: "toilet.passed.unsure"
                ) {
                    nothingPassed = false
                    outcome = .uncertain
                }
            }
        }
    }

    private var nothingPassedQuestion: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.notpassed.title")
            HStack(spacing: DesignTokens.Spacing.small) {
                ChoiceChip(
                    titleKey: "toilet.outcome.bloodOrMucusOnly",
                    isSelected: outcome == .bloodOrMucusOnly,
                    identifier: "toilet.outcome.bloodOrMucusOnly"
                ) {
                    outcome = .bloodOrMucusOnly
                }
                ChoiceChip(
                    titleKey: "toilet.outcome.urgeOnly",
                    isSelected: outcome == .urgeOnly,
                    identifier: "toilet.outcome.urgeOnly"
                ) {
                    outcome = .urgeOnly
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
}
