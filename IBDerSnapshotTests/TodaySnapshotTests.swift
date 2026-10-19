@testable import IBDer
import SnapshotTesting
import SwiftUI
import XCTest

/// Records the Today screen as an image. The baseline lives in git, so any change to what the
/// screen looks like shows up as a PNG in the pull request — the cheapest evidence channel for
/// a reviewer who does not read code.
///
/// The date is pinned: with a live date every baseline would change at midnight.
///
/// A missing baseline is recorded and the test fails — that is how SnapshotTesting works.
/// To accept an intended change, delete the PNG under __Snapshots__ and run again.
@MainActor
final class TodaySnapshotTests: XCTestCase {
    /// A fixed day, so the header text is stable.
    private let day = Date(timeIntervalSince1970: 1_791_000_000) // 2026-10-03, 09:20 UTC+8

    /// Pixel comparison only means something on the machine that recorded the baselines.
    /// A CI runner has a different simulator build, so it renders different pixels for the same
    /// view — comparing there would fail without anything being wrong. CI still builds the target;
    /// the baselines stay in git, where a reviewer sees them in the pull request diff.
    override func setUpWithError() throws {
        try XCTSkipIf(
            ProcessInfo.processInfo.environment["CI"] != nil,
            "Snapshots are recorded and compared on a fixed simulator, not on the CI runner."
        )
    }

    private func host(_ view: some View) -> UIViewController {
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        return controller
    }

    func testTodayWithRecords() {
        assertSnapshot(
            of: host(TodayView(events: RecordedEvent.sample, day: day)),
            as: .image
        )
    }

    func testEmptyDay() {
        assertSnapshot(
            of: host(TodayView(events: [], day: day)),
            as: .image
        )
    }
}
