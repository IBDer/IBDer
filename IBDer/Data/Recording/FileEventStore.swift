import Foundation

/// One JSON archive on disk, written atomically.
///
/// A deliberately small engine: the dataset is one person's records, the format is readable, and a
/// backup later means copying this file (docs/adr/0015-record-storage-engine.md).
actor FileEventStore: EventStore {
    static let currentSchemaVersion = 1

    private let fileURL: URL
    private let write: @Sendable (Data, URL) throws -> Void
    private var cache: Archive?

    init(
        fileURL: URL,
        write: @escaping @Sendable (Data, URL) throws -> Void = FileEventStore.writeAtomically
    ) {
        self.fileURL = fileURL
        self.write = write
    }

    /// The store the app uses: Application Support, never the Documents directory.
    static func appStore() throws -> FileEventStore {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return FileEventStore(fileURL: root.appending(path: "IBDer/records.json"))
    }

    func events(in day: DayRange) async throws -> [RecordedEvent] {
        try load().events
            .filter { !$0.isDeleted && day.contains($0.happenedAt) }
            .sorted { $0.happenedAt < $1.happenedAt }
    }

    func allEvents() async throws -> [RecordedEvent] {
        try load().events
            .filter { !$0.isDeleted }
            .sorted { $0.happenedAt > $1.happenedAt }
    }

    func save(_ event: RecordedEvent) async throws {
        var archive = try load()
        if let index = archive.events.firstIndex(where: { $0.id == event.id }) {
            archive.events[index] = event
        } else {
            archive.events.append(event)
        }
        try commit(archive)
    }

    func delete(_ id: UUID, at now: Date) async throws {
        var archive = try load()
        guard let index = archive.events.firstIndex(where: { $0.id == id }) else { return }
        archive.events[index].deletedAt = now
        try commit(archive)
    }

    func restore(_ id: UUID) async throws {
        var archive = try load()
        guard let index = archive.events.firstIndex(where: { $0.id == id }) else { return }
        archive.events[index].deletedAt = nil
        try commit(archive)
    }

    // MARK: - Archive

    struct Archive: Codable, Equatable, Sendable {
        var schemaVersion: Int
        var events: [RecordedEvent]
    }

    /// In memory only after the file accepted the write, so a failure cannot masquerade as a saved
    /// record.
    private func commit(_ archive: Archive) throws {
        let data: Data
        do {
            data = try Self.encoder.encode(archive)
        } catch {
            throw EventStoreError.writeFailed(String(describing: error))
        }
        do {
            try write(data, fileURL)
        } catch {
            throw EventStoreError.writeFailed(String(describing: error))
        }
        cache = archive
    }

    private func load() throws -> Archive {
        if let cache {
            return cache
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            let empty = Archive(schemaVersion: Self.currentSchemaVersion, events: [])
            cache = empty
            return empty
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
        cache = archive
        return archive
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
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }
}
