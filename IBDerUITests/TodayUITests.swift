import XCTest

/// Task 4.1 verification: the four recording entry points exist and are one tap away.
/// Queries identifiers, never labels, so the test survives a language change.
final class TodayUITests: XCTestCase {
    private func launchEmptyDay() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-emptyDay"]
        app.launch()
        return app
    }

    func testFourEntryPointsAreOneTapAway() {
        let app = launchEmptyDay()

        for identifier in ["entry.toilet", "entry.meal", "entry.medication", "entry.infusion"] {
            let chip = app.buttons[identifier]
            XCTAssertTrue(chip.waitForExistence(timeout: 10), "missing entry point: \(identifier)")
            XCTAssertTrue(chip.isHittable, "entry point is not tappable: \(identifier)")
        }
    }

    func testAnEmptyDaySaysSo() {
        let app = launchEmptyDay()
        XCTAssertTrue(
            app.staticTexts["today.empty.title"].waitForExistence(timeout: 10),
            "an empty day must say so rather than show a blank area"
        )
    }
}
