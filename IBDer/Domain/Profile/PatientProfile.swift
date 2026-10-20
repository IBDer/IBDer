import Foundation

/// What the app knows about the person using it. Every field is optional: a patient may decline any
/// of them and still use the app (ADR-0009, AGENTS.md section 5).
struct PatientProfile: Codable, Sendable, Equatable {
    enum Diagnosis: String, Codable, Sendable, CaseIterable {
        case crohns
        case colitis
        case unsure
    }

    /// Quoted from the care team. Never calculated, never used in one.
    enum DiseaseState: String, Codable, Sendable, CaseIterable {
        case remission
        case active
        case unsure
    }

    enum Treatment: String, Codable, Sendable, CaseIterable {
        case biologic
        case oralMedication
        case exclusiveEnteral
        case partialEnteral
        case otherDiet
        case none
    }

    /// Broad groups on purpose: a patient can say "perianal" without naming a fistula.
    enum Complication: String, Codable, Sendable, CaseIterable {
        case perianal
        case skin
        case joints
        case eyes
        case mouthUlcers
        case liverBiliary
        case anaemiaNutrition
    }

    var heightCentimetres: Double?
    var weightKilograms: Double?
    /// When the weight was entered, so a dose suggestion can say how old it is.
    var weightRecordedAt: Date?
    var diagnosis: Diagnosis?
    var diseaseState: DiseaseState = .unsure
    var treatments: Set<Treatment> = []
    var complications: Set<Complication> = []
    var hasCompletedOnboarding = false

    var hasAnything: Bool {
        heightCentimetres != nil
            || weightKilograms != nil
            || diagnosis != nil
            || !treatments.isEmpty
            || !complications.isEmpty
    }
}
