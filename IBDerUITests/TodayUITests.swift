import XCTest

/// The recording path as a patient walks it: one tap to the sheet, one tap to record, and the
/// fact is on the day.
final class TodayUITests: XCTestCase {
    private func launchEmptyDay() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-inMemory"]
        app.launch()
        return app
    }

    func testThreeEntryPointsAreOneTapAway() {
        let app = launchEmptyDay()

        for identifier in ["entry.toilet", "entry.meal", "entry.medication"] {
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

    func testRecordingAToiletEventPutsItInTheDay() {
        let app = launchEmptyDay()
        app.buttons["entry.toilet"].tap()

        let stool = app.buttons["toilet.outcome.stool"]
        XCTAssertTrue(stool.waitForExistence(timeout: 10), "the four outcomes should appear at once")
        stool.tap()

        let save = app.buttons["common.save"]
        XCTAssertTrue(save.waitForEnabled(timeout: 5), "an outcome unlocks saving")
        save.tap()

        let row = app.descendants(matching: .any).matching(identifier: "timeline.toilet").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "the saved fact belongs on that day")
        XCTAssertFalse(app.staticTexts["today.empty.title"].exists, "the day is no longer empty")
    }

    func testRecordingASupplementKeepsTheScoopCount() {
        let app = launchEmptyDay()
        app.buttons["entry.meal"].tap()

        let supplement = app.buttons["meal.kind.supplement"]
        XCTAssertTrue(supplement.waitForExistence(timeout: 10))
        supplement.tap()

        app.buttons["common.save"].tap()

        let row = app.descendants(matching: .any).matching(identifier: "timeline.meal").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "the powder is its own record, not a meal flag")
        XCTAssertTrue(row.label.contains("6"), "the scoop count survives the save")
    }

    func testTheDayCanBeChanged() {
        let app = launchEmptyDay()
        let date = app.staticTexts["today.date"]
        let todayText = date.label
        XCTAssertTrue(date.waitForExistence(timeout: 10))

        app.buttons["today.previousDay"].tap()
        XCTAssertNotEqual(date.label, todayText, "the header follows the day being looked at")
        XCTAssertTrue(
            app.staticTexts["today.empty.title"].waitForExistence(timeout: 10),
            "yesterday has no records in this launch"
        )
    }
}

private extension XCUIElement {
    func waitForEnabled(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
