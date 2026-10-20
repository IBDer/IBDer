import Foundation
@testable import IBDer
import Testing

/// Task 3.x: the file archive keeps records, reports failures, and refuses to destroy them.
struct FileEventStoreTests {
    private func makeURL() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "ibder-test-\(UUID().uuidString)")
            .appending(path: "records.json")
    }

    private func event(at day: Int, hour: Int = 9) -> RecordedEvent {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        let happenedAt = calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))
            ?? Date(timeIntervalSince1970: 0)
        return RecordedEvent(happenedAt: happenedAt, payload: .toilet(ToiletEvent(outcome: .stool, bristol: .type3)))
    }

    private var day: DayRange {
        DayRange.containing(event(at: 20).happenedAt)
    }

    @Test func aSavedRecordIsThereAfterRelaunch() async throws {
        let url = makeURL()
        let saved = event(at: 20)
        try await FileEventStore(fileURL: url).save(saved)

        let reopened = FileEventStore(fileURL: url)
        let events = try await reopened.events(in: day)
        #expect(events.map(\.id) == [saved.id])
        #expect(events.first?.payload.toiletEvent?.bristol == .type3)
    }

    @Test func savingTheSameIdentifierReplacesTheRecord() async throws {
        let store = FileEventStore(fileURL: makeURL())
        var saved = event(at: 20)
        try await store.save(saved)
        saved.payload = .toilet(ToiletEvent(outcome: .stool, bristol: .type7))
        try await store.save(saved)

        let events = try await store.events(in: day)
        #expect(events.count == 1)
        #expect(events.first?.payload.toiletEvent?.bristol == .type7)
    }

    @Test func aDayOnlyReturnsItsOwnRecords() async throws {
        let store = FileEventStore(fileURL: makeURL())
        try await store.save(event(at: 20))
        try await store.save(event(at: 21))

        #expect(try await store.events(in: day).count == 1)
        #expect(try await store.allEvents().count == 2)
    }

    @Test func deletingRemovesItFromTheDayAndUndoRestoresTheSameRecord() async throws {
        let store = FileEventStore(fileURL: makeURL())
        let saved = event(at: 20)
        try await store.save(saved)

        try await store.delete(saved.id, at: .now)
        #expect(try await store.events(in: day).isEmpty)

        try await store.restore(saved.id)
        let events = try await store.events(in: day)
        #expect(events.map(\.id) == [saved.id])
        #expect(events.first?.revisions.isEmpty == true)
    }

    @Test func aFailedWriteIsReportedAndNothingLooksSaved() async throws {
        let url = makeURL()
        let store = FileEventStore(fileURL: url, write: { _, _ in throw CocoaError(.fileWriteUnknown) })

        do {
            try await store.save(event(at: 20))
            Issue.record("a failed write must not succeed silently")
        } catch let error as EventStoreError {
            guard case .writeFailed = error else {
                Issue.record("unexpected error \(error)")
                return
            }
        }
        #expect(try await store.events(in: day).isEmpty)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func aNewerSchemaIsRefusedRatherThanDiscarded() async throws {
        let url = makeURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(#"{"schemaVersion":99,"events":[]}"#.utf8).write(to: url)

        do {
            _ = try await FileEventStore(fileURL: url).allEvents()
            Issue.record("a newer schema must be refused")
        } catch let error as EventStoreError {
            #expect(error == .unsupportedSchema(99))
        }
    }

    @Test func anUnreadableFileIsReported() async throws {
        let url = makeURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not an archive".utf8).write(to: url)

        do {
            _ = try await FileEventStore(fileURL: url).allEvents()
            Issue.record("a corrupt file must be reported")
        } catch let error as EventStoreError {
            guard case .unreadableArchive = error else {
                Issue.record("unexpected error \(error)")
                return
            }
        }
    }

    /// Pins the on-disk format: if this fixture stops decoding, a previously saved archive breaks.
    @Test func theVersionOneFileFormatStillOpensWithItsHistory() async throws {
        let url = makeURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let fixture = #"""
        {
          "schemaVersion" : 1,
          "events" : [
            {
              "id" : "11111111-1111-1111-1111-111111111111",
              "happenedAt" : "2026-10-19T00:20:00Z",
              "recordedAt" : "2026-10-20T13:00:00Z",
              "completeness" : "everyOne",
              "payload" : {
                "kind" : "toilet",
                "toilet" : { "outcome" : "stool", "bristol" : 4, "blood" : "none", "note" : "" }
              },
              "revisions" : [
                {
                  "replacedAt" : "2026-10-20T14:00:00Z",
                  "happenedAt" : "2026-10-19T00:20:00Z",
                  "completeness" : "everyOne",
                  "payload" : {
                    "kind" : "toilet",
                    "toilet" : { "outcome" : "stool", "bristol" : 6, "blood" : "none", "note" : "" }
                  }
                }
              ],
              "deletedAt" : null
            }
          ]
        }
        """#
        try Data(fixture.utf8).write(to: url)

        let events = try await FileEventStore(fileURL: url).allEvents()
        #expect(events.count == 1)
        #expect(events.first?.id == UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        #expect(events.first?.payload.toiletEvent?.bristol == .type4)
        #expect(events.first?.revisions.first?.payload.toiletEvent?.bristol == .type6)
    }
}
