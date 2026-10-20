@testable import IBDer
import SnapshotTesting
import SwiftUI
import XCTest

/// Records the Today screen as an image. The baseline lives in git, so any change to what the
/// screen looks like shows up as a PNG in the pull request — the cheapest evidence channel for
/// a reviewer who does not read code.
///
/// The date is pinned: with a live date every baseline would change at midnight. A missing
/// baseline is recorded and the test fails; that is how SnapshotTesting works. To accept an
/// intended change, delete the PNG under __Snapshots__ and run again.
@MainActor
final class TodaySnapshotTests: XCTestCase {
    /// 2026-10-03, 09:20 UTC+8 — a fixed day, so the header text is stable.
    private let day = Date(timeIntervalSince1970: 1_791_000_000)

    /// The runtime the baselines belong to. Font rendering and a few control metrics change
    /// between iOS releases, so the same view produces different pixels on 26.5 and 27.0.
    private static let recordedOSMajor = 27

    override func setUpWithError() throws {
        let major = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        try XCTSkipIf(
            major != Self.recordedOSMajor,
            "Baselines belong to iOS \(Self.recordedOSMajor); this runtime is iOS \(major)."
        )
    }

    private func host(_ view: some View) -> UIViewController {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        return controller
    }

    private func model(with events: [RecordedEvent]) -> RecordsModel {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return RecordsModel(store: InMemoryEventStore(events: events), day: day, events: events)
    }

    private func sampleEvents() -> [RecordedEvent] {
        func at(_ hour: Int, _ minute: Int) -> Date {
            Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }
        return [
            RecordedEvent(
                happenedAt: at(7, 20),
                recordedAt: at(7, 21),
                payload: .toilet(ToiletEvent(outcome: .stool, bristol: .type4))
            ),
            RecordedEvent(
                happenedAt: at(8, 0),
                recordedAt: at(8, 0),
                payload: .medication(MedicationEvent(name: "Mesalazine", dose: .known(500), unit: "mg"))
            ),
            RecordedEvent(
                happenedAt: at(8, 15),
                recordedAt: at(8, 16),
                payload: .meal(MealEvent(kind: .supplement, scoops: 6))
            ),
            RecordedEvent(
                happenedAt: at(13, 40),
                recordedAt: at(13, 40),
                payload: .toilet(ToiletEvent(outcome: .urgeOnly, bristol: nil))
            ),
        ]
    }

    func testTodayWithRecords() {
        let events = sampleEvents()
        assertSnapshot(of: host(TodayView(model: model(with: events))), as: .image)
    }

    func testEmptyDay() {
        assertSnapshot(of: host(TodayView(model: model(with: []))), as: .image)
    }
}
