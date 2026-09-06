//
// Copyright © 2023 Alexander Romanov
// AppSettingsDestinations.swift, created on 25.09.2023
//

import NavigatorUI
import OversizeKit
import OversizeUI
import SwiftUI

enum AppSettingsDestinations: Hashable {
    case appSettings
}

extension AppSettingsDestinations: NavigationDestination {
    var body: some View {
        switch self {
        case .appSettings:
            AppSettingsPageView()
        }
    }
}

struct AppSettingsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTab.settings.id) { navigator in
            SettingsView {
                AppSettingsView {
                    navigator.navigate(to: AppSettingsDestinations.appSettings)
                }
            }
            .navigationDestination(AppSettingsDestinations.self)
            .navigationAutoReceive(AppSettingsDestinations.self)
            .navigationDestination(SettingsDestinations.self)
            .navigationAutoReceive(SettingsDestinations.self)
        }
        .coreServices()
    }
}

#Preview {
    AppSettingsNavigationStack()
}
