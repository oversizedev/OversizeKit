//
// Copyright © 2026 Alexander Romanov
// ExampleOnboardingUITests.swift, created on 06.09.2026
//

import XCTest

final class ExampleOnboardingUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingShowsTitleAndAction() {
        let app = XCUIApplication.launchWithResetOnboarding()

        XCTAssertTrue(
            app.staticTexts[UITestIdentifier.onboardingTitle].waitForExistence(timeout: UITestTimeout.screen),
            "Onboarding title is missing"
        )
        XCTAssertTrue(
            app.buttons[UITestIdentifier.onboardingContinue].isHittable,
            "Onboarding action is not reachable"
        )
    }

    @MainActor
    func testCompletingOnboardingRevealsMainScreen() {
        let app = XCUIApplication.launchWithResetOnboarding()
        app.completeOnboarding()

        XCTAssertTrue(
            app.otherElements[UITestIdentifier.mainScreen].waitForExistence(timeout: UITestTimeout.screen),
            "Main screen did not render after onboarding completed"
        )
    }
}
