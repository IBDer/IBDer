import Foundation

/// A value that is allowed to be unknown. Unknown and a known zero stay different facts.
enum Reading<Value: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    case unknown
    case known(Value)

    var value: Value? {
        switch self {
        case .unknown: nil
        case let .known(value): value
        }
    }

    var isKnown: Bool {
        if case .known = self {
            true
        } else {
            false
        }
    }
}
