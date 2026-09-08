//
// Copyright © 2026 Alexander Romanov
// UITestingSupport.swift, created on 06.09.2026
//

#if DEBUG
import Foundation
import OversizeServices

enum UITestingSupport {
    private enum StorageKey {
        static let premiumState = "AppState.PremiumState"
        static let appRunCount = "AppState.appRunCount"
        static let isAppReviewed = "AppState.isAppReviewd"
    }

    static func applyLaunchArgumentsIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains(UITestLaunchArguments.resetOnboarding) {
            AppStateService().resetOnboarding()
        }

        // Launcher presents the paywall and the rate prompt over the content for
        // non-premium users, and AppStoreReviewService requests the system review
        // alert on specific launch counts; both would cover the screen under test.
        if arguments.contains(UITestLaunchArguments.suppressInterstitials) {
            UserDefaults.standard.set(true, forKey: StorageKey.premiumState)
            UserDefaults.standard.set(true, forKey: StorageKey.isAppReviewed)
            UserDefaults.standard.set(1000, forKey: StorageKey.appRunCount)
        }
    }
}
#endif
