//
// Copyright © 2026 Alexander Romanov
// RootTabView.swift, created on 06.09.2026
//

import SwiftUI

struct RootTabView: View {
    @State private var selection: RootTab = .main

    var body: some View {
        TabView(selection: $selection) {
            ForEach(RootTab.allCases) { tab in
                destination(for: tab)
                    .tag(tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
    }

    @ViewBuilder
    private func destination(for tab: RootTab) -> some View {
        switch tab {
        case .main:
            MainNavigationStack()
        case .demo:
            DemoNavigationStack()
        case .settings:
            AppSettingsNavigationStack()
        }
    }
}

#Preview {
    RootTabView()
}
