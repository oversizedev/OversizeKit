//
// Copyright © 2022 Alexander Romanov
// SystemServices.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeLockscreen
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
    @Injected(\.settingsService) var settingsService
    @Injected(\.appStoreReviewService) var appStoreReviewService

    @AppStorage("AppState.PremiumState") var isPremium: Bool = false

    @StateObject var hudState = HUD()
    @State var blurRadius: CGFloat = 0
    @State var oppacity: CGFloat = 1

    @State public var pinCodeField: String = ""
    @State public var authState: LockscreenViewState = .locked
    @State var activeFullScreenSheet: FullScreenSheet?

    @State var isShwoLock = false

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
                            // withAnimation {
                            blurRadius = 0
                            oppacity = 1
                            //  }
                        }
                    case .background:
                        if settingsService.blurMinimizeEnabend {
                            // withAnimation {
                            blurRadius = 10
                            oppacity = 0
                            // }
                        }
                    case .inactive:
                        if settingsService.blurMinimizeEnabend {
                            // withAnimation {
                            blurRadius = 10
                            oppacity = 0
                            //   }
                        }
                    @unknown default:
                        break
                    }
                })
//            Group {
//                if activeFullScreenSheet == .lockscreen {
//                    lockscreenView
//                } else {
//                    content
//                }
//            }

                // defaults
//                .sheet(isPresented: $isShwoLock) {
//                    if activeFullScreenSheet == .lockscreen {
//                        lockscreenView
//                    }
//                }
                .opacity(oppacity)
                .blur(radius: blurRadius)
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
