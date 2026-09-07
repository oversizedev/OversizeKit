//
// Copyright © 2023 Alexander Romanov
// ExampleApp.swift, created on 25.09.2023
//

import NavigatorUI
import OversizeKit
import SwiftUI

@main
struct ExampleApp: App {
    @State private var deeplink: URL?

    init() {
        #if DEBUG
        UITestingSupport.applyLaunchArgumentsIfNeeded()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Launcher {
                RootView(deeplink: $deeplink)
            }
            .onboarding {
                OnboardingView()
            }
            // Attached above Launcher so links received while onboarding or the
            // lockscreen is shown are not dropped.
            .onOpenURL { deeplink = $0 }
            .onDeeplink { deeplink = $0 }
        }
    }
}
