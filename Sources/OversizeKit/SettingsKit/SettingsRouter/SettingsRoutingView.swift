//
// Copyright © 2025 Alexander Romanov
// SettingsRoutingView.swift, created on 05.03.2025
//

import OversizeRouter
import SwiftUI

public struct SettingsTabRoutingView: View {
    @State private var router: TabRouter<SettingsTab> = .init(
        selection: .general,
        tabs: [
            SettingsTab.general,
            SettingsTab.apperance,
            SettingsTab.syncrhonization,
            SettingsTab.security,
            SettingsTab.help,
            SettingsTab.about,
        ]
    )

    private var height: CGFloat {
        switch router.selection {
        case .general:
            500
        case .apperance:
            460
        case .syncrhonization:
            100
        case .security:
            400
        case .help:
            300
        case .about:
            600
        }
    }

    public init() {}

    public var body: some View {
        RoutingTabView(router: router)
            .frame(width: 550, height: height)
    }
}

extension SettingsTab: TabableView {
    public func view() -> some View {
        switch self {
        case .general:
            RoutingView<SettingsView, SettingsScreen> {
                SettingsView {
                    // Нужно сюда передать View, например AppSettingsView
                }
            }
            .systemServices()
        case .security:
            RoutingView<SecuritySettingsView, SettingsScreen> {
                SecuritySettingsView()
            }
            .systemServices()
        case .help:
            RoutingView<SupportView, SettingsScreen> {
                SupportView()
            }
            .systemServices()
        case .apperance:
            RoutingView<AppearanceSettingView, SettingsScreen> {
                AppearanceSettingView()
            }
            .systemServices()
        case .syncrhonization:
            RoutingView<iCloudSettingsView, SettingsScreen> {
                iCloudSettingsView()
            }
            .systemServices()
        case .about:
            RoutingView<AboutView, SettingsScreen> {
                AboutView()
            }
            .systemServices()
        }
    }
}
