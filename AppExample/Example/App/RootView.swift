//
// Copyright © 2026 Alexander Romanov
// RootView.swift, created on 06.09.2026
//

import NavigatorUI
import OversizeKit
import SwiftUI

struct RootView: View {
    @Binding private var deeplink: URL?
    @State private var navigator: Navigator = .init(configuration: .init())
    @State private var selectedTab: RootTab = .main

    init(deeplink: Binding<URL?>) {
        _deeplink = deeplink
    }

    var body: some View {
        RootTabView(selection: $selectedTab)
            .navigationRoot(navigator)
            .task(id: deeplink) { handlePendingDeeplink() }
    }

    private func handlePendingDeeplink() {
        guard let url = deeplink,
              let host = URLComponents(url: url, resolvingAgainstBaseURL: true)?.host
        else { return }

        switch host {
        case "settings":
            selectedTab = .settings
            navigator.named(RootTab.settings.id)?.popAll()
        case "premium":
            selectedTab = .settings
            navigator.navigate(to: SettingsDestinations.premium)
        default:
            break
        }

        deeplink = nil
    }
}

#Preview {
    RootView(deeplink: .constant(nil))
        .coreServices()
}
