import Foundation
@testable import IBDer
import Testing

/// Task 2.x: the record envelope, the day window and the counts that must never lie.
struct RecordSemanticsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))
            ?? Date(timeIntervalSince1970: 0)
    }

    private func stool(at happenedAt: Date, recordedAt: Date? = nil) -> RecordedEvent {
        RecordedEvent(
            happenedAt: happenedAt,
            recordedAt: recordedAt ?? happenedAt,
            payload: .toilet(ToiletEvent(outcome: .stool, bristol: .type4))
        )
    }

    @Test func backfilledRecordsKeepBothTimestamps() {
        let event = stool(at: date(19, 8), recordedAt: date(20, 21))
        #expect(event.happenedAt == date(19, 8))
        #expect(event.recordedAt == date(20, 21))
        #expect(event.isBackfilled(calendar: calendar))
    }

    @Test func aRecordEnteredTheSameDayIsNotBackfilled() {
        let event = stool(at: date(20, 8), recordedAt: date(20, 8, 30))
        #expect(!event.isBackfilled(calendar: calendar))
    }

    @Test func editingKeepsThePreviousValueAndTheOriginalRecordedAt() {
        let event = stool(at: date(20, 8), recordedAt: date(20, 8, 1))
        let edited = event.applying(
            .init(payload: .toilet(ToiletEvent(outcome: .stool, bristol: .type6))),
            at: date(20, 22)
        )

        #expect(edited.payload.toiletEvent?.bristol == .type6)
        #expect(edited.revisions.count == 1)
        #expect(edited.revisions.first?.payload.toiletEvent?.bristol == .type4)
        #expect(edited.recordedAt == event.recordedAt)
        #expect(edited.id == event.id)
    }

    @Test func anEditThatChangesNothingAddsNoRevision() {
        let event = stool(at: date(20, 8))
        let edited = event.applying(.init(payload: event.payload), at: date(20, 22))
        #expect(edited.revisions.isEmpty)
    }

    @Test func urgeOnlyIsNeverACountedBowelMovement() {
        let urge = RecordedEvent(
            happenedAt: date(20, 9),
            payload: .toilet(ToiletEvent(outcome: .urgeOnly, bristol: nil))
        )
        let blood = RecordedEvent(
            happenedAt: date(20, 10),
            payload: .toilet(ToiletEvent(outcome: .bloodOrMucusOnly, bristol: nil))
        )
        let moved = stool(at: date(20, 11))

        #expect(DayTotals.bowelMovements(in: [urge, blood, moved]) == 1)
    }

    @Test func deletedRecordsLeaveTheCount() {
        var event = stool(at: date(20, 8))
        #expect(DayTotals.bowelMovements(in: [event]) == 1)
        event.deletedAt = date(20, 9)
        #expect(DayTotals.bowelMovements(in: [event]) == 0)
    }

    @Test func aDayRunsFromMidnightToMidnight() {
        let day = DayRange.containing(date(20, 12), calendar: calendar)
        #expect(day.contains(date(20, 0, 0)))
        #expect(day.contains(date(20, 23, 59)))
        #expect(!day.contains(date(21, 0, 0)))
        #expect(!day.contains(date(19, 23, 59)))
    }

    @Test func midnightBelongsToTheNewDay() {
        let evening = DayRange.containing(date(20, 23, 59), calendar: calendar)
        let morning = DayRange.containing(date(21, 0, 1), calendar: calendar)
        #expect(!evening.contains(date(21, 0, 0)))
        #expect(morning.contains(date(21, 0, 0)))
    }

    @Test func unknownIsNotZero() {
        let unknown: Reading<Double> = .unknown
        let zero: Reading<Double> = .known(0)
        #expect(unknown != zero)
        #expect(zero.isKnown)
        #expect(!unknown.isKnown)
    }

    @Test func everyCompletenessStateSurvivesEncoding() throws {
        for state in Completeness.allCases {
            let data = try JSONEncoder().encode(state)
            #expect(try JSONDecoder().decode(Completeness.self, from: data) == state)
        }
    }

    @Test func theFutureIsRejectedAndThePastIsAccepted() {
        let now = date(20, 12)
        #expect(RecordingPolicy.accepts(happenedAt: date(19, 12), now: now))
        #expect(RecordingPolicy.accepts(happenedAt: now, now: now))
        #expect(!RecordingPolicy.accepts(happenedAt: date(21, 12), now: now))
    }
}
