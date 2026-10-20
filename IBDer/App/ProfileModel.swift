import Foundation
import Observation

/// The profile as the screens see it: one value, saved as a whole.
@MainActor
@Observable
final class ProfileModel {
    private let store: any ProfileStoring
    private(set) var profile: PatientProfile
    var failure: String?

    init(store: any ProfileStoring, profile: PatientProfile = PatientProfile()) {
        self.store = store
        self.profile = profile
    }

    static func live() -> ProfileModel {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-inMemory") {
            var profile = PatientProfile()
            // A UI test that only cares about recording should not have to walk the profile.
            if arguments.contains("-skipOnboarding") {
                profile.hasCompletedOnboarding = true
            }
            return ProfileModel(store: InMemoryProfileStore(profile: profile), profile: profile)
        }
        if let store = try? FileProfileStore.appStore() {
            return ProfileModel(store: store)
        }
        return ProfileModel(store: InMemoryProfileStore())
    }

    var needsOnboarding: Bool {
        !profile.hasCompletedOnboarding
    }

    func load() async {
        do {
            profile = try await store.load()
        } catch {
            failure = String(describing: error)
        }
    }

    @discardableResult
    func save(_ updated: PatientProfile) async -> Bool {
        do {
            try await store.save(updated)
            profile = updated
            return true
        } catch {
            failure = String(describing: error)
            return false
        }
    }
}
