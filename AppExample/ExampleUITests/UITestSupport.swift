//
// Copyright © 2026 Alexander Romanov
// UITestSupport.swift, created on 06.09.2026
//

import XCTest

enum UITestTimeout {
    static let launch: TimeInterval = 30
    static let screen: TimeInterval = 15
}

enum UITestIdentifier {
    static let onboardingTitle = "onboarding.title"
    static let onboardingContinue = "onboarding.continue"
    static let mainScreen = "main.screen"
    static let appSettingsRow = "settings.appSection.row"
    static let appSettingsPage = "settings.appSettingsPage.screen"
}

extension XCUIApplication {
    static func launchWithResetOnboarding() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            UITestLaunchArguments.resetOnboarding,
            UITestLaunchArguments.suppressInterstitials,
        ]
        app.launch()
        return app
    }

    func completeOnboarding() {
        let continueButton = buttons[UITestIdentifier.onboardingContinue]
        guard continueButton.waitForExistence(timeout: UITestTimeout.screen) else {
            XCTFail("Onboarding did not appear, so it could not be completed")
            return
        }
        continueButton.tap()
    }

    func openSettingsTab() {
        let settingsTab = tabBars.buttons["Settings"]
        guard settingsTab.waitForExistence(timeout: UITestTimeout.screen) else {
            XCTFail("Settings tab is not available")
            return
        }
        settingsTab.tap()
    }
}
