//
// Copyright © 2022 Alexander Romanov
// AppLauncher.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeModules
import OversizeLockscreen
import OversizeSecurityService
import OversizeServices
import OversizeSettingsService
import OversizeStore
import OversizeStoreService
import OversizeUI
import SDWebImageSVGCoder
import SwiftUI

public struct AppLauncher<Content: View, Onboarding: View>: View {
    @Environment(\.scenePhase) var scenePhase

    private var onboarding: Onboarding?
    private let content: Content
    private var transaction = Transaction()

    @StateObject private var viewModel = AppLauncherViewModel()
    @State private var blurRadius: CGFloat = 0

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        contentView
            .onAppear {
//                #if DEBUG
//                    viewModel.appStateService.restOnbarding()
//                    viewModel.appStateService.restAppRunCount()
//                #endif
                viewModel.appStateService.appRun()
                viewModel.checkOnboarding()
                viewModel.checkPremium()
                SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
            }
            .fullScreenCover(item: $viewModel.activeFullScreenSheet) {
                fullScreenCover(sheet: $0)
                    .systemServices()
            }
            .onChange(of: viewModel.appStateService.isCompletedOnbarding) { isCompletedOnbarding in
                if isCompletedOnbarding, viewModel.appStateService.appRunCount == 1, !viewModel.isPremium {
                    viewModel.setPayWall()
                }
            }
            .onChange(of: scenePhase, perform: { value in
                switch value {
                case .active, .inactive:
                    break
                case .background:
                    viewModel.authState = .locked
                    viewModel.pinCodeField = ""
                @unknown default:
                    log("unknown")
                }
            })
    }
    
    var contentView: some View {
        Group {
            if viewModel.isShowLockscreen {
                lockscreenView
            } else {
                content
                    .onAppear {
                        viewModel.reviewService.appRunRequest()
                    }
            }
        }
    }

    @ViewBuilder
    private func fullScreenCover(sheet: AppLauncherViewModel.FullScreenSheet) -> some View {
        switch sheet {
        case .onboarding: onboarding
        case .payWall: StoreView().closable()
        }
    }
    
    private var lockscreenView: some View {
        LockscreenView(pinCode: $viewModel.pinCodeField,
                       state: $viewModel.authState,
                       title: L10n.Security.enterPINCode,
                       errorText: L10n.Security.invalidPIN,
                       pinCodeEnabled: viewModel.settingsService.pinCodeEnabend,
                       biometricEnabled: viewModel.settingsService.biometricEnabled,
                       biometricType: viewModel.biometricService.biometricType) {
            self.viewModel.checkPassword()
        } biometricAction: {
            self.viewModel.appLockValidation()
        }
        .onAppear {
            if viewModel.settingsService.biometricEnabled, scenePhase != .background {
                viewModel.appLockValidation()
            }
        }
    }

    public func onboarding(@ViewBuilder onboarding: @escaping () -> Onboarding) -> AppLauncher {
        var control = self
        control.onboarding = onboarding()
        return control
    }
}

public extension AppLauncher where Onboarding == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        onboarding = nil
    }
}

public extension View {
    func appLaunch() -> some View {
        AppLauncher {
            self
        }
        .systemServices()
    }

    func appLaunch<Onboarding: View>(@ViewBuilder onboarding: @escaping () -> Onboarding) -> some View {
        AppLauncher {
            self
        }
        .onboarding(onboarding: onboarding)
        .systemServices()
    }
}

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

struct LockscreenView_Previews: PreviewProvider {
    static var previews: some View {
        AppLauncher {
            Text("Succes")
        }
    }
}
