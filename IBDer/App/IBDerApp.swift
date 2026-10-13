import SwiftUI

@main
struct IBDerApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()            // RootView is kept for the placeholder until routing lands.
        }
    }
}

/// Placeholder root until the first feature lands (see
/// openspec/changes/add-v1-recording-core/tasks.md).
struct RootView: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Text("IBDer")
                .font(DesignTokens.Typography.display)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Text(String(localized: "app.root.placeholder"))
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .padding(DesignTokens.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Color.background)
    }
}
