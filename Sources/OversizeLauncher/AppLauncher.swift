//
// Copyright © 2022 Alexander Romanov
// AppLauncher.swift
//

import OversizeLocalizable
import OversizeModules
import OversizePINCode
import OversizeServices
import OversizeSettingsService
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
        lockscreen(FeatureFlags.secure.lookscreen.valueOrFalse)
            .onAppear {
                viewModel.appStateService.appRun()
                #if DEBUG
                    viewModel.appStateService.restOnbarding()
                #endif
                viewModel.checkOnboarding()

                viewModel.checkPremium()
                // StoreKitLegacyProductsService.shared.initializeAndCheckPremiun()
                SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
            }
            .onChange(of: scenePhase, perform: { value in
                switch value {
                case .active:
                    withAnimation {
                        blurRadius = 0
                    }

                case .background:
                    if viewModel.settingsService.blurMinimizeEnabend {
                        withAnimation {
                            blurRadius = 10
                        }
                    }
                case .inactive:
                    if viewModel.settingsService.blurMinimizeEnabend {
                        withAnimation {
                            blurRadius = 10
                        }
                    }
                @unknown default:
                    print("unknown")
                }
            })
            .fullScreenCover(item: $viewModel.activeFullScreenSheet) {
                fullScreenCover(sheet: $0)
                    .systemServices()
            }
    }

    @ViewBuilder
    private func fullScreenCover(sheet: AppLauncherViewModel.FullScreenSheet) -> some View {
        switch sheet {
        case .onboarding: onboarding
        }
    }

    @ViewBuilder
    private func lockscreen(_ featureFlag: Bool) -> some View {
        switch featureFlag {
        case true:
            contentAndLoclscreenView

        case false:
            contentView
        }
    }

    private var contentView: some View {
        content
            .blur(radius: blurRadius)
            .onChange(of: scenePhase, perform: { value in
                switch value {
                case .active, .inactive:
                    break
                case .background:
                    viewModel.authState = .locked
                    viewModel.pinCodeField = ""

                @unknown default:
                    print("unknown")
                }
            })

            .onAppear {
                viewModel.reviewService.appRunRequest()
            }
    }

    private var contentAndLoclscreenView: some View {
        ZStack {
            if viewModel.settingsService.pinCodeEnabend || viewModel.settingsService.biometricEnabled,
               viewModel.authState != .unlocked
            {
                PINCodeView(pinCode: $viewModel.pinCodeField,
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
            } else {
                contentView
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
