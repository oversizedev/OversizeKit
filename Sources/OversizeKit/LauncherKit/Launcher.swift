//
// Copyright © 2023 Alexander Romanov
// Launcher.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

public struct Launcher<Content: View, Onboarding: View>: View {
    @Environment(\.scenePhase) var scenePhase

    private var onboarding: Onboarding?
    private let content: Content
    private var transaction = Transaction()

    @StateObject private var viewModel = LauncherViewModel()
    @State private var blurRadius: CGFloat = 0

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        contentView
            .onAppear {
                viewModel.isShowSplashScreen = false
//                #if DEBUG
//                    viewModel.appStateService.restOnbarding()
//                    viewModel.appStateService.restAppRunCount()
//                #endif
                viewModel.appStateService.appRun()
            }
            .task {
                await viewModel.checkPremium()
            }
            .appLaunchCover(item: $viewModel.activeFullScreenSheet) {
                fullScreenCover(sheet: $0)
                    .systemServices()
            }
            .onChange(of: viewModel.appStateService.isCompletedOnbarding) { isCompletedOnbarding in
                if isCompletedOnbarding, !viewModel.isPremium {
                    viewModel.setPayWall()
                } else {
                    viewModel.activeFullScreenSheet = nil
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
            if viewModel.isShowSplashScreen {
                SplashScreen()
            } else if viewModel.isShowLockscreen {
                lockscreenView
            } else {
                content
                    .onAppear {
                        viewModel.reviewService.launchEvent()
                        viewModel.launcherSheetsChek()
                    }
            }
        }
    }

    @ViewBuilder
    private func fullScreenCover(sheet: LauncherViewModel.FullScreenSheet) -> some View {
        switch sheet {
        case .onboarding: onboarding
        case .payWall: StoreInstuctinsView()
        case .rate: RateAppScreen()
        case let .specialOffer(event): StoreSpecialOfferView(event: event)
        }
    }

    private var lockscreenView: some View {
        LockscreenView(pinCode: $viewModel.pinCodeField,
                       state: $viewModel.authState,
                       title: L10n.Security.enterPINCode,
                       errorText: L10n.Security.invalidPIN,
                       pinCodeEnabled: viewModel.settingsService.pinCodeEnabend,
                       biometricEnabled: viewModel.settingsService.biometricEnabled,
                       biometricType: viewModel.biometricService.biometricType)
        {
            viewModel.checkPassword()
        } biometricAction: {
            viewModel.appLockValidation()
        }
        .onAppear {
            if viewModel.settingsService.biometricEnabled, scenePhase != .background {
                viewModel.appLockValidation()
            }
        }
    }

    public func onboarding(@ViewBuilder onboarding: @escaping () -> Onboarding) -> Launcher {
        var control = self
        control.onboarding = onboarding()
        return control
    }
}

public extension Launcher where Onboarding == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        onboarding = nil
    }
}

public extension View {
    func appLaunch() -> some View {
        Launcher {
            self
        }
        .systemServices()
    }

    func appLaunch(@ViewBuilder onboarding: @escaping () -> some View) -> some View {
        Launcher {
            self
        }
        .onboarding(onboarding: onboarding)
        .systemServices()
    }
}

private extension View {
    func appLaunchCover<Item>(
        item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View where Item: Identifiable {
        #if os(macOS)
            interactiveDismissDisabled()
                .sheet(item: item, onDismiss: onDismiss, content: content)
        #else
            fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        #endif
    }
}

struct LockscreenView_Previews: PreviewProvider {
    static var previews: some View {
        Launcher {
            Text("Succes")
        }
    }
}
