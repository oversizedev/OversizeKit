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

    @StateObject private var viewModel = LauncherViewModel()

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
                #if os(macOS)
                    .frame(width: 840, height: 672)
                    // .interactiveDismissDisabled(!viewModel.appStateService.isCompletedOnbarding)
                #endif
            }
            .onChange(of: viewModel.appStateService.isCompletedOnbarding) { _, isCompletedOnbarding in
                if isCompletedOnbarding, !viewModel.isPremium {
                    viewModel.setPayWall()
                } else {
                    viewModel.activeFullScreenSheet = nil
                }
            }
            .onChange(of: scenePhase) { _, value in
                switch value {
                case .background:
                    viewModel.authState = .locked
                    viewModel.pinCodeField = ""
                default:
                    break
                }
            }
    }

    @ViewBuilder
    var contentView: some View {
        if viewModel.isShowSplashScreen {
            SplashScreen()
        } else if viewModel.isShowLockscreen {
            lockscreenView
        } else {
            content
                .onAppear {
                    Task { @MainActor in
                        await viewModel.reviewService.launchEvent()
                    }
                    viewModel.launcherSheetsChek()
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
        LockscreenView(
            pinCode: $viewModel.pinCodeField,
            state: $viewModel.authState,
            title: L10n.Security.enterPINCode,
            errorText: L10n.Security.invalidPIN,
            pinCodeEnabled: viewModel.settingsService.pinCodeEnabend,
            biometricEnabled: viewModel.settingsService.biometricEnabled,
            biometricType: viewModel.biometricService.biometricType
        ) {
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
    }

    func appLaunch(@ViewBuilder onboarding: @escaping () -> some View) -> some View {
        Launcher {
            self
        }
        .onboarding(onboarding: onboarding)
    }
}

private extension View {
    func appLaunchCover<Item>(
        item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View where Item: Identifiable {
        #if os(macOS)
            sheet(item: item, onDismiss: onDismiss, content: content)
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
