import SwiftUI

/// Three tabs: what happened today, what it adds up to, and the settings behind both.
struct RootView: View {
    let model: RecordsModel
    let profile: ProfileModel

    var body: some View {
        TabView {
            TodayView(model: model)
                .tabItem { Label("tab.today", systemImage: "calendar") }

            TrendsView()
                .tabItem { Label("tab.trends", systemImage: "chart.bar.xaxis") }

            SettingsView(profile: profile)
                .tabItem { Label("tab.settings", systemImage: "person.crop.circle") }
        }
        .tint(DesignTokens.Color.accent)
    }
}
