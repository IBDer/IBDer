import Foundation

/// Where the profile lives. One value, replaced as a whole; never mixed with the event archive.
protocol ProfileStoring: Sendable {
    func load() async throws -> PatientProfile
    func save(_ profile: PatientProfile) async throws
}

/// The same versioned, atomic pattern as the record archive (ADR-0015): a failed write leaves the
/// previous profile untouched.
actor FileProfileStore: ProfileStoring {
    static let currentSchemaVersion = 1

    private let fileURL: URL
    private let write: @Sendable (Data, URL) throws -> Void
    private var cache: PatientProfile?

    init(fileURL: URL, write: @escaping @Sendable (Data, URL) throws -> Void = FileProfileStore.writeAtomically) {
        self.fileURL = fileURL
        self.write = write
    }

    static func appStore() throws -> FileProfileStore {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return FileProfileStore(fileURL: root.appending(path: "IBDer/profile.json"))
    }

    func load() async throws -> PatientProfile {
        if let cache {
            return cache
        }
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            cache = PatientProfile()
            return PatientProfile()
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
        cache = archive.profile
        return archive.profile
    }

    func save(_ profile: PatientProfile) async throws {
        let archive = Archive(schemaVersion: Self.currentSchemaVersion, profile: profile)
        let data: Data
        do {
            data = try Self.encoder.encode(archive)
            try write(data, fileURL)
        } catch {
            throw EventStoreError.writeFailed(String(describing: error))
        }
        cache = profile
    }

    struct Archive: Codable, Sendable {
        var schemaVersion: Int
        var profile: PatientProfile
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

/// Previews, tests and `-inMemory` launches.
actor InMemoryProfileStore: ProfileStoring {
    private var profile: PatientProfile

    init(profile: PatientProfile = PatientProfile()) {
        self.profile = profile
    }

    func load() async throws -> PatientProfile {
        profile
    }

    func save(_ profile: PatientProfile) async throws {
        self.profile = profile
    }
}
