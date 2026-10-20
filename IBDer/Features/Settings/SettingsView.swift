import SwiftUI

/// The settings tab. Today it holds the profile and the truth about where the data lives.
struct SettingsView: View {
    let profile: ProfileModel
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("profile.height", value: heightText)
                    LabeledContent("profile.weight", value: weightText)
                } header: {
                    Text("profile.section.body")
                }

                Section {
                    LabeledContent("profile.diagnosis", value: diagnosisText)
                    LabeledContent("profile.state", value: stateText)
                    LabeledContent("profile.complications", value: complicationsText)
                } header: {
                    Text("profile.section.disease")
                }

                Section {
                    LabeledContent("profile.treatment", value: treatmentText)
                } header: {
                    Text("profile.section.treatment")
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
                }

                Section {
                    LabeledContent("settings.version") {
                        Text(verbatim: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                }

                // The floating tab bar covers the last rows; this keeps the version readable.
                Section {
                    Color.clear
                        .frame(height: 56)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.Color.background)
            // The floating tab bar sits over the list; keep the last row clear of it.
            .contentMargins(.bottom, 96, for: .scrollContent)
            .navigationTitle("settings.title")
            .toolbar {
                Button("profile.edit") { isEditing = true }
                    .accessibilityIdentifier("profile.edit")
            }
            .sheet(isPresented: $isEditing) {
                ProfileEditor(profile: profile) { isEditing = false }
            }
        }
    }

    private var heightText: String {
        guard let height = profile.profile.heightCentimetres else { return String(localized: "profile.empty") }
        return "\(height.formatted(.number.precision(.fractionLength(0 ... 1)))) " +
            String(localized: "profile.height.unit")
    }

    private var weightText: String {
        guard let weight = profile.profile.weightKilograms else { return String(localized: "profile.empty") }
        return "\(weight.formatted(.number.precision(.fractionLength(0 ... 1)))) " +
            String(localized: "profile.weight.unit")
    }

    private var diagnosisText: String {
        switch profile.profile.diagnosis {
        case .crohns: String(localized: "profile.diagnosis.crohns")
        case .colitis: String(localized: "profile.diagnosis.colitis")
        case .unsure: String(localized: "profile.diagnosis.unsure")
        case nil: String(localized: "profile.empty")
        }
    }

    private var stateText: String {
        switch profile.profile.diseaseState {
        case .inactive: String(localized: "profile.state.inactive")
        case .active: String(localized: "profile.state.active")
        case .unsure: String(localized: "profile.state.unsure")
        }
    }

    private var complicationsText: String {
        let items = profile.profile.complications
        guard !items.isEmpty else { return String(localized: "profile.empty") }
        return items
            .sorted { $0.rawValue < $1.rawValue }
            .map { complicationName($0) }
            .joined(separator: "、")
    }

    private var treatmentText: String {
        let items = profile.profile.treatments
        guard !items.isEmpty else { return String(localized: "profile.empty") }
        return items
            .sorted { $0.rawValue < $1.rawValue }
            .map { treatmentName($0) }
            .joined(separator: "、")
    }

    private func complicationName(_ item: PatientProfile.Complication) -> String {
        switch item {
        case .perianal: String(localized: "profile.complication.perianal")
        case .skin: String(localized: "profile.complication.skin")
        case .joints: String(localized: "profile.complication.joints")
        case .eyes: String(localized: "profile.complication.eyes")
        case .mouthUlcers: String(localized: "profile.complication.mouthUlcers")
        case .liverBiliary: String(localized: "profile.complication.liverBiliary")
        case .anaemiaNutrition: String(localized: "profile.complication.anaemiaNutrition")
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

/// Editing the profile later uses the same three pages as the first launch.
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
