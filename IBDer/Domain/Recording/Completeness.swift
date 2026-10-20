import Foundation

/// How completely one observation was captured. Never inferred from the presence of events.
enum Completeness: String, Codable, Sendable, CaseIterable {
    case everyOne
    case totalsOnly
    case approximate
    case notRecorded
}
