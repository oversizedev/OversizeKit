//
// Copyright © 2024 Alexander Romanov
// Example__watchOS_App.swift, created on 19.05.2024
//

import Factory
import OversizeKit
import OversizeServices
import OversizeUI
import SwiftUI

@main
struct Example__watchOS__Watch_AppApp: App {
    
    @Injected(\.appStateService) var appStateService: AppStateService
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
