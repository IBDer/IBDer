import Foundation

/// Everything the biologic slice keeps: one arrangement, its expected doses and the doses that
/// actually happened. Separate from the daily records, which are a different kind of fact.
struct BiologicState: Codable, Sendable, Equatable {
    var plan: BiologicPlan?
    var doses: [PlannedDose] = []
    var records: [InfusionRecord] = []

    var hasPlan: Bool {
        plan != nil
    }
}

protocol BiologicStoring: Sendable {
    func load() async throws -> BiologicState
    func save(_ state: BiologicState) async throws
}

/// The same versioned, atomic pattern as the other stores (ADR-0015).
actor FileBiologicStore: BiologicStoring {
    static let currentSchemaVersion = 1

    private let fileURL: URL
    private let write: @Sendable (Data, URL) throws -> Void
    private var cache: BiologicState?

    init(fileURL: URL, write: @escaping @Sendable (Data, URL) throws -> Void = FileBiologicStore.writeAtomically) {
        self.fileURL = fileURL
        self.write = write
    }

    static func appStore() throws -> FileBiologicStore {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return FileBiologicStore(fileURL: root.appending(path: "IBDer/biologics.json"))
    }

    func load() async throws -> BiologicState {
        if let cache {
            return cache
        }
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            cache = BiologicState()
            return BiologicState()
        }
        let data = try Data(contentsOf: fileURL)
        let archive: Archive
        do {
            archive = try Self.decoder.decode(Archive.self, from: data)
        } catch {
            throw EventStoreError.unreadableArchive(String(describing: error))
        }
        guard archive.schemaVersion <= Self.currentSchemaVersion else {
            throw EventStoreError.unsupportedSchema(archive.schemaVersion)
        }
        cache = archive.state
        return archive.state
    }

    func save(_ state: BiologicState) async throws {
        let archive = Archive(schemaVersion: Self.currentSchemaVersion, state: state)
        do {
            let data = try Self.encoder.encode(archive)
            try write(data, fileURL)
            cache = state
        } catch {
            throw EventStoreError.writeFailed(String(describing: error))
        }
    }

    struct Archive: Codable, Sendable {
        var schemaVersion: Int
        var state: BiologicState
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static func writeAtomically(_ data: Data, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}

actor InMemoryBiologicStore: BiologicStoring {
    private var state: BiologicState

    init(state: BiologicState = BiologicState()) {
        self.state = state
    }

    func load() async throws -> BiologicState {
        state
    }

    func save(_ state: BiologicState) async throws {
        self.state = state
    }
}
