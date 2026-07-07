import XCTest

final class BudgetjarUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<30 {
            app.buttons["addButton"].tap()
            let titleField = app.textFields["titleField"]
            guard titleField.waitForExistence(timeout: 2) else { break }
            titleField.tap()
            titleField.typeText("Entry \(i)")
            app.buttons["saveButton"].tap()
        }
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissesOnTapOutside() {
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testCancelDiscardsEntry() {
        app.buttons["addButton"].tap()
        app.buttons["cancelButton"].tap()
        XCTAssertFalse(app.staticTexts["Test Entry Cancel"].exists)
    }

    func testSettingsSheetOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
