//
// Copyright © 2026 Alexander Romanov
// ExampleLaunchUITests.swift, created on 06.09.2026
//

import XCTest

final class ExampleLaunchUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsOnboardingWhenOnboardingIsReset() {
        let app = XCUIApplication.launchWithResetOnboarding()

        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: UITestTimeout.launch),
            "App did not reach the foreground after launch"
        )

        XCTAssertTrue(
            app.buttons[UITestIdentifier.onboardingContinue].waitForExistence(timeout: UITestTimeout.screen),
            "Onboarding did not render after launching with a reset onboarding state"
        )
    }

    @MainActor
    func testOnboardingIsSkippedOnSecondLaunch() {
        let app = XCUIApplication.launchWithResetOnboarding()
        app.completeOnboarding()
        app.terminate()

        app.launchArguments = [UITestLaunchArguments.suppressInterstitials]
        app.launch()

        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: UITestTimeout.screen),
            "Root tab bar did not render on a launch with completed onboarding"
        )
        XCTAssertFalse(
            app.buttons[UITestIdentifier.onboardingContinue].exists,
            "Onboarding was shown again after it had been completed"
        )
    }
}
