//
// Copyright © 2023 Alexander Romanov
// SystemServices.swift
//

import FactoryKit
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct SystemServicesModifier: ViewModifier {
    @Injected(\.appStateService) private var appState: AppStateService
    @Injected(\.settingsService) private var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) private var appStoreReviewService: AppStoreReviewService

    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    @Environment(\.theme) private var theme: ThemeSettings
    @AppStorage("AppState.PremiumState") private var isPremium: Bool = false

    @State private var blurRadius: CGFloat = 0
    @State private var oppacity: CGFloat = 1

    private enum FullScreenSheet: Identifiable, Equatable, Sendable {
        case onboarding
        case payWall
        case lockscreen
        var id: Int {
            hashValue
        }
    }

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

public extension View {
    @available(*, deprecated, renamed: "coreServices", message: "Renamed")
    func systemServices() -> some View {
        modifier(SystemServicesModifier())
    }

    func coreServices() -> some View {
        modifier(SystemServicesModifier())
    }
}
