//
// Copyright © 2023 Alexander Romanov
// SystemServices.swift
//

import Factory
import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct SystemServicesModifier: ViewModifier {
    @Injected(\.appStateService) var appState: AppStateService
    @Injected(\.settingsService) var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) var appStoreReviewService: AppStoreReviewServiceProtocol

    @Environment(\.scenePhase) var scenePhase: ScenePhase
    @Environment(\.theme) var theme: ThemeSettings
    @AppStorage("AppState.PremiumState") var isPremium: Bool = false

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
    
    @State private var screnSize: ScreenSize = .init(width: 375, height: 667)

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
                .onAppear {
                    let updatedScreenSize = ScreenSize(geometry: geometry)
                    screnSize = updatedScreenSize
                }
                .blur(radius: blurRadius)
                .preferredColorScheme(theme.appearance.colorScheme)
            #if os(iOS)
                .accentColor(theme.accentColor)
            #endif
                .premiumStatus(isPremium)
                .theme(ThemeSettings())
               .screenSize(screnSize)
        }
    }
}

public extension View {
    func systemServices() -> some View {
        modifier(SystemServicesModifier())
    }
}
