import SwiftUI

/// The words the profile uses. Kept in one place so the form and the summary cannot drift.
enum ProfileLabels {
    static func diagnosis(_ item: PatientProfile.Diagnosis) -> LocalizedStringKey {
        switch item {
        case .crohns: "profile.diagnosis.crohns"
        case .colitis: "profile.diagnosis.colitis"
        case .unsure: "profile.diagnosis.unsure"
        }
    }

    static func state(_ item: PatientProfile.DiseaseState) -> LocalizedStringKey {
        switch item {
        case .inactive: "profile.state.inactive"
        case .active: "profile.state.active"
        case .unsure: "profile.state.unsure"
        }
    }

    static func complication(_ item: PatientProfile.Complication) -> LocalizedStringKey {
        switch item {
        case .perianal: "profile.complication.perianal"
        case .skin: "profile.complication.skin"
        case .joints: "profile.complication.joints"
        case .eyes: "profile.complication.eyes"
        case .mouthUlcers: "profile.complication.mouthUlcers"
        case .liverBiliary: "profile.complication.liverBiliary"
        case .anaemiaNutrition: "profile.complication.anaemiaNutrition"
        }
    }

    static func treatment(_ item: PatientProfile.Treatment) -> LocalizedStringKey {
        switch item {
        case .biologic: "profile.treatment.biologic"
        case .oralMedication: "profile.treatment.oralMedication"
        case .exclusiveEnteral: "profile.treatment.exclusiveEnteral"
        case .partialEnteral: "profile.treatment.partialEnteral"
        case .otherDiet: "profile.treatment.otherDiet"
        case .none: "profile.treatment.none"
        }
    }
}
