import SwiftUI

/// The settings tab. M1 has almost nothing to configure on purpose; what is here is true today.
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
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
                    HStack {
                        Text("settings.version")
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                        Spacer()
                        Text(verbatim: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.Color.background)
            .navigationTitle("settings.title")
        }
    }
}
