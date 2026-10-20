import SwiftUI

/// The first launch. Three pages, each one skippable, and the app is usable whatever is answered.
struct OnboardingView: View {
    let model: ProfileModel
    @State private var draft = PatientProfile()

    var body: some View {
        ProfileFormView(draft: $draft, isOnboarding: true) {
            Task { await model.save(draft) }
        }
        .task {
            draft = model.profile
        }
    }
}
