//
// Copyright © 2025 Alexander Romanov
// SettingsTabRoutingView.swift, created on 07.03.2025
//

import OversizeRouter
import OversizeUI
import SwiftUI

public struct SettingsTabRoutingView<AppSettingsViewType: View>: View {
    @State private var router: TabRouter<SettingsTab> = .init(
        selection: .general,
        tabs: [
            SettingsTab.general,
            SettingsTab.apperance,
            // SettingsTab.syncrhonization,
            SettingsTab.security,
            // SettingsTab.about
        ]
    )

    private var height: CGFloat {
        switch router.selection {
        case .general:
            450
        case .apperance:
            450
        case .syncrhonization:
            90
        case .security:
            220
        case .help:
            300
        case .about:
            600
        }
    }

    private let appSettingsViewBuilder: () -> AppSettingsViewType

    public init(@ViewBuilder appSettingsViewBuilder: @escaping () -> AppSettingsViewType) {
        self.appSettingsViewBuilder = appSettingsViewBuilder
    }

    public var body: some View {
        RoutingTabView(router: router)
            .frame(width: 550, height: height)
            .environment(\.appSettingsViewBuilder, makeViewBuilderBox())
    }

    private func makeViewBuilderBox() -> ViewBuilderBox {
        ViewBuilderBox(appSettingsViewBuilder: { AnyView(appSettingsViewBuilder()) })
    }
}

public class ViewBuilderBox {
    public let appSettingsViewBuilder: () -> AnyView

    public init(appSettingsViewBuilder: @escaping () -> AnyView) {
        self.appSettingsViewBuilder = appSettingsViewBuilder
    }
}

private struct AppSettingsViewBuilderKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = ViewBuilderBox(appSettingsViewBuilder: { AnyView(EmptyView()) })
}

public extension EnvironmentValues {
    var appSettingsViewBuilder: ViewBuilderBox {
        get { self[AppSettingsViewBuilderKey.self] }
        set { self[AppSettingsViewBuilderKey.self] = newValue }
    }
}

extension SettingsTab: TabableView {
    public func view() -> some View {
        switch self {
        case .general:
            RoutingView<SettingsGenericWrapper, SettingsScreen> {
                SettingsGenericWrapper()
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

// Generic wrapper to handle passing the AppSettingsView to SettingsView
public struct SettingsGenericWrapper: View {
    @Environment(\.appSettingsViewBuilder) private var appSettingsViewBuilder

    public init() {}

    public var body: some View {
        SettingsView {
            appSettingsViewBuilder.appSettingsViewBuilder()
        }
    }
}
