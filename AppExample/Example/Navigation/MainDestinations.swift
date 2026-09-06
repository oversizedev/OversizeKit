//
// Copyright © 2026 Alexander Romanov
// MainDestinations.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeKit
import SwiftUI

struct MainNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTab.main.id) {
            MainView()
        }
        .coreServices()
    }
}

#Preview {
    MainNavigationStack()
}
