//
// Copyright © 2026 Alexander Romanov
// RootView.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeKit
import SwiftUI

struct RootView: View {
    @State private var navigator: Navigator = .init(configuration: .init())
    @State private var selectedTab: RootTab = .main

    var body: some View {
        RootTabView(selection: $selectedTab)
            .navigationRoot(navigator)
            .onOpenURL { handle($0) }
            .onDeeplink { handle($0) }
    }

    private func handle(_ url: URL) {
        guard let host = URLComponents(url: url, resolvingAgainstBaseURL: true)?.host else { return }

        switch host {
        case "settings":
            selectedTab = .settings
        case "premium":
            selectedTab = .settings
            navigator.navigate(to: SettingsDestinations.premium)
        default:
            break
        }
    }
}

#Preview {
    RootView()
        .coreServices()
}
