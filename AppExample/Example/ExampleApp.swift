//
// Copyright © 2023 Alexander Romanov
// ExampleApp.swift, created on 25.09.2023
//

import OversizeKit
import SwiftUI

@main
struct ExampleApp: App {
    init() {
        #if DEBUG
        UITestingSupport.applyLaunchArgumentsIfNeeded()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Launcher {
                RootView()
            }
            .onboarding {
                OnboardingView()
            }
        }
    }
}
