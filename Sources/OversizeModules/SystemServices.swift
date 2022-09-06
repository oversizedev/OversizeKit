//
// Copyright © 2022 Alexander Romanov
// SystemServices.swift
//

import OversizeSecurityService
import OversizeServices
import OversizeSettingsService
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct SystemServicesModifier: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.theme) var theme

    @Injected(\.biometricService) var biometricService
    @Injected(\.appStateService) var appState
    @Injected(\.settingsService) var settingsStore
    @Injected(\.appStoreReviewService) var appStoreReviewService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false

    @StateObject var hudState = HUD()
    @State var blurRadius: CGFloat = 0

    public init() {}

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content

                // defaults
                // .blur(radius: blurRadius)
                .preferredColorScheme(theme.appearance.colorScheme)
            #if os(iOS)
                .accentColor(theme.accentColor)
            #endif
                //! !!! Premium
                .premiumStatus(isPremium)
                .theme(ThemeSettings())
                .screenSize(geometry)

                // overlays
                .hud(isPresented: $hudState.isPresented, type: $hudState.type) {
                    HUDContent(title: hudState.title, image: hudState.image, type: hudState.type)
                }
//            .onChange(of: scenePhase, perform: { value in
//                switch value {
//                case .active:
//                    blurRadius = 0
//                case .background:
//                    if settingsStore.blurMinimizeEnabend {
//                        blurRadius = 10
//                    }
//                case .inactive:
//                    if settingsStore.blurMinimizeEnabend {
//                        blurRadius = 10
//                    }
//                @unknown default:
//                    log("unknown")
//                }
//            })

                // services
                .environmentObject(hudState)
            /// PROOOO
            // .environmentObject(productsStore)
            // .environmentObject(settingsStore)
            // .environmentObject(Self.appState)
            // .environmentObject(Self.biometricService)
            // .environmentObject(Self.reviewService)
        }
    }
}

public extension View {
    func systemServices() -> some View {
        modifier(SystemServicesModifier())
    }
}
