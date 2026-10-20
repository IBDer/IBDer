import Foundation
@testable import IBDer
import Testing

/// The profile is a few self-reported facts. It must round-trip, survive relaunch and never invent a
/// value the patient did not give.
struct PatientProfileTests {
    private func filled() -> PatientProfile {
        var profile = PatientProfile()
        profile.heightCentimetres = 170
        profile.weightKilograms = 62
        profile.weightRecordedAt = Date(timeIntervalSince1970: 1_791_000_000)
        profile.diagnosis = .crohns
        profile.diseaseState = .inactive
        profile.treatments = [.biologic, .partialEnteral]
        profile.complications = [.perianal]
        profile.hasCompletedOnboarding = true
        return profile
    }

    private func makeURL() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "ibder-profile-\(UUID().uuidString)")
            .appending(path: "profile.json")
    }

    @Test func theProfileRoundTripsThroughTheFile() async throws {
        let url = makeURL()
        try await FileProfileStore(fileURL: url).save(filled())

        let reopened = FileProfileStore(fileURL: url)
        let loaded = try await reopened.load()
        #expect(loaded == filled())
    }

    @Test func aMissingFileIsAnEmptyProfileNotAFailure() async throws {
        let loaded = try await FileProfileStore(fileURL: makeURL()).load()
        #expect(loaded == PatientProfile())
        #expect(loaded.hasCompletedOnboarding == false)
    }

    @Test func aFailedWriteLeavesThePreviousProfile() async throws {
        let url = makeURL()
        let store = FileProfileStore(fileURL: url, write: { _, _ in throw CocoaError(.fileWriteUnknown) })

        do {
            try await store.save(filled())
            Issue.record("a failed write must not succeed silently")
        } catch let error as EventStoreError {
            guard case .writeFailed = error else {
                Issue.record("unexpected error \(error)")
                return
            }
        }
        #expect(try await store.load() == PatientProfile())
    }

    @Test func nothingFilledInStillHasAnEmptyProfile() {
        let profile = PatientProfile()
        #expect(profile.hasAnything == false)
        #expect(profile.diseaseState == .unsure, "an unanswered state is unsure, never active")
    }

    @Test func treatmentsAreASetNotALadder() {
        var profile = PatientProfile()
        profile.treatments = [.biologic, .partialEnteral]
        #expect(profile.treatments.count == 2)
    }
}
