import SwiftUI

@main
struct IBDerApp: App {
    @State private var model = RecordsModel.live()
    @State private var profile = ProfileModel.live()
    @State private var biologic = BiologicModel.live()
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !isReady {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(DesignTokens.Color.background)
                } else if profile.needsOnboarding {
                    OnboardingView(model: profile)
                } else {
                    RootView(model: model, profile: profile, biologic: biologic)
                }
            }
            .task {
                await profile.load()
                await biologic.load()
                isReady = true
            }
        }
    }
}
