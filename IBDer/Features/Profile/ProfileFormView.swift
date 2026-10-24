import SwiftUI

/// The three pages of the profile: the body, the disease, the treatment. Used both for the first
/// launch and for editing later, so the two can never drift apart.
struct ProfileFormView: View {
    @Binding var draft: PatientProfile
    let isOnboarding: Bool
    let onFinish: () -> Void
    var onCancel: (() -> Void)?

    @State private var step = 0
    @State private var heightText: String
    @State private var weightText: String

    init(
        draft: Binding<PatientProfile>,
        isOnboarding: Bool,
        onFinish: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        _draft = draft
        self.isOnboarding = isOnboarding
        self.onFinish = onFinish
        self.onCancel = onCancel
        _heightText = State(initialValue: Self.text(draft.wrappedValue.heightCentimetres))
        _weightText = State(initialValue: Self.text(draft.wrappedValue.weightKilograms))
    }

    private static let stepCount = 3

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    switch step {
                    case 0: bodyPage
                    case 1: diseasePage
                    default: treatmentPage
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, DesignTokens.Spacing.large)
            }
            bottomBar
        }
        .background(DesignTokens.Color.background)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Text(titleKey)
                    .font(DesignTokens.Typography.display)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Spacer()
                if let onCancel {
                    Button("common.cancel") { onCancel() }
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            Text(subtitleKey)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            pageDots
                .padding(.top, DesignTokens.Spacing.xSmall)
        }
        .padding(.horizontal, DesignTokens.Spacing.regular)
        .padding(.top, DesignTokens.Spacing.large)
        .padding(.bottom, DesignTokens.Spacing.medium)
    }

    private var pageDots: some View {
        HStack(spacing: DesignTokens.Spacing.xSmall) {
            ForEach(0 ..< Self.stepCount, id: \.self) { index in
                Capsule()
                    .fill(index == step ? DesignTokens.Color.accent : DesignTokens.Color.border)
                    .frame(width: index == step ? 22 : 8, height: 4)
            }
        }
        .animation(.snappy(duration: 0.2), value: step)
    }

    private var titleKey: LocalizedStringKey {
        switch step {
        case 0: "profile.page.body.title"
        case 1: "profile.page.disease.title"
        default: "profile.page.treatment.title"
        }
    }

    private var subtitleKey: LocalizedStringKey {
        switch step {
        case 0: "profile.page.body.subtitle"
        case 1: "profile.page.disease.subtitle"
        default: "profile.page.treatment.subtitle"
        }
    }

    // MARK: - Pages

    // MARK: - Bottom

    private var bottomBar: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            if step > 0 {
                Button {
                    back()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                        .frame(
                            width: DesignTokens.Layout.minimumTouchTarget,
                            height: DesignTokens.Layout.minimumTouchTarget
                        )
                        .background(
                            DesignTokens.Color.surface,
                            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("profile.back"))
                .accessibilityIdentifier("profile.back")
            }
            if isOnboarding {
                Button("profile.skip") { advance() }
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .accessibilityIdentifier("profile.skip")
            }
            PrimaryButton(
                titleKey: step == Self.stepCount - 1 ? "profile.finish" : "profile.next",
                identifier: "profile.next"
            ) {
                advance()
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .background(DesignTokens.Color.background)
    }

    private func back() {
        applyNumbers()
        guard step > 0 else { return }
        withAnimation(.snappy(duration: 0.22)) { step -= 1 }
    }

    private func advance() {
        applyNumbers()
        if step < Self.stepCount - 1 {
            withAnimation(.snappy(duration: 0.22)) { step += 1 }
        } else {
            draft.hasCompletedOnboarding = true
            onFinish()
        }
    }

    private func applyNumbers() {
        let height = Double(heightText.replacingOccurrences(of: ",", with: "."))
        let weight = Double(weightText.replacingOccurrences(of: ",", with: "."))
        draft.heightCentimetres = height
        if let weight, weight != draft.weightKilograms {
            draft.weightKilograms = weight
            draft.weightRecordedAt = .now
        } else if weight == nil {
            draft.weightKilograms = nil
            draft.weightRecordedAt = nil
        }
    }

    // MARK: - Pieces

    private func diagnosisChip(_ item: PatientProfile.Diagnosis) -> some View {
        ChoiceChip(
            titleKey: ProfileLabels.diagnosis(item),
            isSelected: draft.diagnosis == item,
            identifier: "profile.diagnosis.\(item.rawValue)"
        ) {
            draft.diagnosis = draft.diagnosis == item ? nil : item
        }
    }

    private func stateChip(_ item: PatientProfile.DiseaseState) -> some View {
        ChoiceChip(
            titleKey: ProfileLabels.state(item),
            isSelected: draft.diseaseState == item,
            identifier: "profile.state.\(item.rawValue)"
        ) {
            draft.diseaseState = item
        }
    }

    private func toggle<T: Hashable>(_ item: T, in set: inout Set<T>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }

    private static func text(_ value: Double?) -> String {
        guard let value else { return "" }
        return value.formatted(.number.precision(.fractionLength(0 ... 1)).grouping(.never))
    }
}

extension ProfileFormView {
    private var bodyPage: some View {
        VStack(spacing: DesignTokens.Spacing.small) {
            NumberRow(
                titleKey: "profile.height",
                identifier: "profile.height",
                placeholder: "profile.height.placeholder",
                unit: "profile.height.unit",
                text: $heightText
            )
            NumberRow(
                titleKey: "profile.weight",
                identifier: "profile.weight",
                placeholder: "profile.weight.placeholder",
                unit: "profile.weight.unit",
                text: $weightText
            )
            Text("profile.weight.note")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
    }

    private var diseasePage: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                SectionTitle(titleKey: "profile.diagnosis")
                ChoiceGrid {
                    diagnosisChip(.crohns)
                    diagnosisChip(.colitis)
                    diagnosisChip(.unsure)
                }
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                SectionTitle(titleKey: "profile.state")
                ChoiceGrid {
                    stateChip(.inactive)
                    stateChip(.active)
                    stateChip(.unsure)
                }
                Text("profile.state.note")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                SectionTitle(titleKey: "profile.complications")
                ChoiceGrid {
                    ForEach(PatientProfile.Complication.allCases, id: \.self) { item in
                        ChoiceChip(
                            titleKey: ProfileLabels.complication(item),
                            isSelected: draft.complications.contains(item),
                            identifier: "profile.complication.\(item.rawValue)"
                        ) {
                            toggle(item, in: &draft.complications)
                        }
                    }
                }
            }
        }
    }

    private var treatmentPage: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "profile.treatment")
            ChoiceGrid {
                ForEach(PatientProfile.Treatment.allCases, id: \.self) { item in
                    ChoiceChip(
                        titleKey: ProfileLabels.treatment(item),
                        isSelected: draft.treatments.contains(item),
                        identifier: "profile.treatment.\(item.rawValue)"
                    ) {
                        toggle(item, in: &draft.treatments)
                    }
                }
            }
        }
    }
}
