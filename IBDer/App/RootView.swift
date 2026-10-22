import SwiftUI

/// Three tabs: what happened today, what it adds up to, and the settings behind both.
struct RootView: View {
    let model: RecordsModel
    let profile: ProfileModel
    let biologic: BiologicModel

    var body: some View {
        TabView {
            TodayView(model: model, biologic: biologic, profile: profile)
                .tabItem { Label("tab.today", systemImage: "calendar") }

            TrendsView(model: model)
                .tabItem { Label("tab.trends", systemImage: "chart.bar.xaxis") }

            SettingsView(profile: profile, biologic: biologic)
                .tabItem { Label("tab.settings", systemImage: "person.crop.circle") }
        }
        .tint(DesignTokens.Color.accent)
    }
}
