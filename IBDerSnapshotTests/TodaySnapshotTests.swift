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

    /// The runtime the baselines belong to. Font rendering and a few control metrics change
    /// between iOS releases, so the same view produces different pixels on 26.5 and 27.0 -
    /// comparing across them fails with nothing wrong. Comparison therefore happens only on the
    /// recording runtime; elsewhere the target still builds and the tests skip.
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
