import SwiftUI

/// The settings tab: who the app thinks you are, the biologic plan, and the truth about the data.
/// Entries, not a form — the values live one level down.
struct SettingsView: View {
    let profile: ProfileModel
    let biologic: BiologicModel

    @State private var isEditing = false
    @State private var showingBiologic = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        isEditing = true
                    } label: {
                        summary
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings.profile")
                }

                Section {
                    Button {
                        showingBiologic = true
                    } label: {
                        entry(title: "biologic.title", value: biologicSummary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings.biologic")
                }

                Section {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                        Text("settings.data.title")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Text("settings.data.body")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                    .padding(.vertical, DesignTokens.Spacing.xSmall)

                    LabeledContent("settings.version") {
                        Text(verbatim: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                } header: {
                    Text("settings.about")
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.Color.background)
            .contentMargins(.bottom, 96, for: .scrollContent)
            .navigationTitle("settings.title")
            .sheet(isPresented: $isEditing) {
                ProfileEditor(profile: profile) { isEditing = false }
            }
            .sheet(isPresented: $showingBiologic) {
                BiologicPlanView(model: biologic, profile: profile)
            }
        }
    }

    private var summary: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            summaryText
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .contentShape(Rectangle())
    }

    private var summaryText: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            Text(headline)
                .font(.title3.weight(.semibold))
                .foregroundStyle(DesignTokens.Color.textPrimary)
                .multilineTextAlignment(.leading)
            Text(subhead)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .contentShape(Rectangle())
    }

    private func entry(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Spacer()
            Text(verbatim: value)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
        .contentShape(Rectangle())
    }

    /// "Crohn's · biologic" while there is something to say; one invitation while there is not.
    private var headline: String {
        guard profile.profile.hasAnything else { return String(localized: "settings.profile.empty") }
        var parts: [String] = []
        if let diagnosis = profile.profile.diagnosis {
            parts.append(diagnosisName(diagnosis))
        }
        if let treatment = profile.profile.treatments.min(by: { $0.rawValue < $1.rawValue }) {
            parts.append(treatmentName(treatment))
        }
        guard !parts.isEmpty else { return String(localized: "settings.profile.empty") }
        return parts.joined(separator: " · ")
    }

    private var subhead: String {
        guard profile.profile.hasAnything else { return String(localized: "settings.profile.emptyHint") }
        return String(localized: "settings.profile.doctorSays")
            + "：" + stateName(profile.profile.diseaseState)
    }

    private var biologicSummary: String {
        guard let plan = biologic.plan else { return String(localized: "biologic.card.setUp") }
        if let name = biologic.displayNameKey {
            return String(localized: String.LocalizationValue(name))
        }
        return plan.customName ?? String(localized: "biologic.card.setUp")
    }

    private func diagnosisName(_ item: PatientProfile.Diagnosis) -> String {
        switch item {
        case .crohns: String(localized: "profile.diagnosis.crohns")
        case .colitis: String(localized: "profile.diagnosis.colitis")
        case .unsure: String(localized: "profile.diagnosis.unsure")
        }
    }

    private func stateName(_ item: PatientProfile.DiseaseState) -> String {
        switch item {
        case .inactive: String(localized: "profile.state.inactive")
        case .active: String(localized: "profile.state.active")
        case .unsure: String(localized: "profile.state.unsure")
        }
    }

    private func treatmentName(_ item: PatientProfile.Treatment) -> String {
        switch item {
        case .biologic: String(localized: "profile.treatment.biologic")
        case .oralMedication: String(localized: "profile.treatment.oralMedication")
        case .exclusiveEnteral: String(localized: "profile.treatment.exclusiveEnteral")
        case .partialEnteral: String(localized: "profile.treatment.partialEnteral")
        case .otherDiet: String(localized: "profile.treatment.otherDiet")
        case .none: String(localized: "profile.treatment.none")
        }
    }
}

/// Editing the profile uses the same three pages as the first launch.
private struct ProfileEditor: View {
    let profile: ProfileModel
    let onClose: () -> Void
    @State private var draft = PatientProfile()

    var body: some View {
        ProfileFormView(
            draft: $draft,
            isOnboarding: false,
            onFinish: {
                Task {
                    await profile.save(draft)
                    onClose()
                }
            },
            onCancel: onClose
        )
        .task { draft = profile.profile }
    }
}
