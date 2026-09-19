//
// Copyright © 2023 Alexander Romanov
// AppEnvironment.swift
//

import FactoryKit
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct AppEnvironmentModifier: ViewModifier {
    @Injected(\.appStateService) private var appState: AppStateService
    @Injected(\.settingsService) private var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) private var appStoreReviewService: AppStoreReviewService

    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    @Environment(\.theme) private var theme: ThemeSettings
    @AppStorage("AppState.PremiumState") private var isPremium: Bool = false

    @State private var blurRadius: CGFloat = 0

    public init() {}

    public func body(content: Content) -> some View {
        content
            .blur(radius: blurRadius)
            .preferredColorScheme(theme.appearance.colorScheme)
            .premiumStatus(isPremium)
            .theme(ThemeSettings())
            #if os(iOS)
            .tint(theme.accentColor)
            #endif
            .onChange(of: scenePhase) { _, phase in
                onChangeScenePhase(phase)
            }
    }

    private func onChangeScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if settingsService.blurMinimizeEnabled {
                withAnimation {
                    blurRadius = 0
                }
            }
        case .background:
            if settingsService.blurMinimizeEnabled {
                withAnimation {
                    blurRadius = 10
                }
            }
        case .inactive:
            if settingsService.blurMinimizeEnabled {
                withAnimation {
                    blurRadius = 10
                }
            }
        @unknown default:
            break
        }
    }
}

// MARK: - Legacy

@available(*, deprecated, message: "Do not inject screen geometry into the environment: read container sizes with readSize or readSafeContentSize")
struct LegacyScreenGeometryModifier: ViewModifier {
    @Environment(\.screenSize) private var resolvedScreenSize: ScreenSize
    @Environment(\.safeAreaInsets) private var resolvedSafeAreaInsets: SwiftUI.EdgeInsets

    @State private var measuredScreenSize: ScreenSize?
    @State private var measuredSafeAreaInsets: SwiftUI.EdgeInsets?

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { updateScreenGeometry(geometry) }
                        .onChange(of: geometry.size) { _, _ in
                            updateScreenGeometry(geometry)
                        }
                        .onChange(of: geometry.safeAreaInsets) { _, _ in
                            updateScreenGeometry(geometry)
                        }
                }
            }
            .screenSize(measuredScreenSize ?? resolvedScreenSize)
            .environment(\.safeAreaInsets, measuredSafeAreaInsets ?? resolvedSafeAreaInsets)
    }

    private func updateScreenGeometry(_ geometry: GeometryProxy) {
        measuredScreenSize = ScreenSize(geometry: geometry)
        measuredSafeAreaInsets = geometry.safeAreaInsets
    }
}

public extension View {
    func appEnvironment() -> some View {
        modifier(AppEnvironmentModifier())
    }

    @available(*, deprecated, renamed: "appEnvironment", message: "Renamed. Unlike coreServices, appEnvironment does not inject screen size and safe area insets into the environment: read container sizes with readSize or readSafeContentSize")
    func coreServices() -> some View {
        modifier(AppEnvironmentModifier())
            .modifier(LegacyScreenGeometryModifier())
    }

    @available(*, deprecated, renamed: "appEnvironment", message: "Renamed. Unlike systemServices, appEnvironment does not inject screen size and safe area insets into the environment: read container sizes with readSize or readSafeContentSize")
    func systemServices() -> some View {
        modifier(AppEnvironmentModifier())
            .modifier(LegacyScreenGeometryModifier())
    }
}
