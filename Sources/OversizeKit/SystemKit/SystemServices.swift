//
// Copyright © 2023 Alexander Romanov
// SystemServices.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct SystemServicesModifier: ViewModifier {
    @Injected(Container.appStateService) var appState: AppStateService
    @Injected(Container.settingsService) var settingsService: SettingsServiceProtocol
    @Injected(Container.appStoreReviewService) var appStoreReviewService: AppStoreReviewServiceProtocol

    @Environment(\.scenePhase) var scenePhase: ScenePhase
    @Environment(\.theme) var theme: ThemeSettings
    @AppStorage("AppState.PremiumState") var isPremium: Bool = false

    @StateObject var hudState = HUD()
    @State var blurRadius: CGFloat = 0
    @State var oppacity: CGFloat = 1

    enum FullScreenSheet: Identifiable, Equatable {
        case onboarding
        case payWall
        case lockscreen
        public var id: Int {
            hashValue
        }
    }

    public init() {}

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onChange(of: scenePhase, perform: { value in
                    switch value {
                    case .active:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 0
                            }
                        }
                    case .background:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 10
                            }
                        }
                    case .inactive:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 10
                            }
                        }
                    @unknown default:
                        break
                    }
                })
                .blur(radius: blurRadius)
                .preferredColorScheme(theme.appearance.colorScheme)
            #if os(iOS)
                .accentColor(theme.accentColor)
            #endif
                .premiumStatus(isPremium)
                .theme(ThemeSettings())
                .screenSize(geometry)
                .hud(isPresented: $hudState.isPresented, type: $hudState.type) {
                    HUDContent(title: hudState.title, image: hudState.image, type: hudState.type)
                }
                .environmentObject(hudState)
        }
    }
}

public extension View {
    func systemServices() -> some View {
        modifier(SystemServicesModifier())
    }
}
