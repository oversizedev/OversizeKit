//
// Copyright © 2026 Alexander Romanov
// ExampleSettingsUITests.swift, created on 06.09.2026
//

import XCTest

final class ExampleSettingsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testAppSectionRowOpensItsScreen() {
        let app = XCUIApplication.launchWithResetOnboarding()
        app.completeOnboarding()
        app.openSettingsTab()

        let appSettingsRow = app.buttons[UITestIdentifier.appSettingsRow]
        XCTAssertTrue(
            appSettingsRow.waitForExistence(timeout: UITestTimeout.screen),
            "The app section passed to SettingsView is not rendered"
        )

        appSettingsRow.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)[UITestIdentifier.appSettingsPage].waitForExistence(timeout: UITestTimeout.screen),
            "Tapping the app section row did not push its destination"
        )
    }

    @MainActor
    func testBuiltInSettingsScreenOpens() {
        let app = XCUIApplication.launchWithResetOnboarding()
        app.completeOnboarding()
        app.openSettingsTab()

        let appearanceRow = app.buttons["Appearance"]
        XCTAssertTrue(
            appearanceRow.waitForExistence(timeout: UITestTimeout.screen),
            "The built-in appearance row is missing from SettingsView"
        )

        appearanceRow.tap()

        XCTAssertTrue(
            app.navigationBars["Appearance"].waitForExistence(timeout: UITestTimeout.screen),
            "SettingsDestinations did not route to the appearance screen"
        )
    }
}
