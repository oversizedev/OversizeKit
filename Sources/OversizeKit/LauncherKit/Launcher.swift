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

    @StateObject private var viewModel: LauncherViewModel

    public init(
        @ViewBuilder content: () -> Content,
        firstRunAction: (() -> Void)? = nil,
        appUpdateAction: (() -> Void)? = nil
    ) {
        self.content = content()
        _viewModel = StateObject(wrappedValue: LauncherViewModel(
            firstRunAction: firstRunAction,
            appUpdateAction: appUpdateAction
        ))
    }

    public var body: some View {
        contentView
            .task(viewModel.onAppear)
            .appLaunchCover(item: $viewModel.activeFullScreenSheet) {
                fullScreenCover(sheet: $0)
                    .systemServices()
                #if os(macOS)
                    .frame(width: viewModel.activeFullScreenSheet == .onboarding ? 840 : 500, height: 672)
                // .interactiveDismissDisabled(!viewModel.appStateService.isCompletedOnbarding)
                #endif
            }
            .onChange(of: viewModel.appStateService.isCompletedOnboarding) { _, isCompletedOnbarding in
                viewModel.onCompeteOnboarding(isCompletedOnbarding)
            }
            .onChange(of: scenePhase) { _, value in
                viewModel.onScenePhaseChange(value)
            }
    }

    @ViewBuilder
    var contentView: some View {
        if viewModel.isShowLockscreen {
            lockscreenView
        } else {
            content
                .onAppear {
                    Task { @MainActor in
                        await viewModel.reviewService.launchEvent()
                        await viewModel.launcherSheetsChek()
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
    init(
        @ViewBuilder content: () -> Content,
        firstRunAction: (() -> Void)? = nil,
        appUpdateAction: (() -> Void)? = nil
    ) {
        self.content = content()
        _viewModel = StateObject(wrappedValue: LauncherViewModel(
            firstRunAction: firstRunAction,
            appUpdateAction: appUpdateAction
        ))
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

    func appLaunch(
        @ViewBuilder onboarding: @escaping () -> some View,
        firstRun: (() -> Void)? = nil,
        appUpdate: (() -> Void)? = nil
    ) -> some View {
        Launcher(
            content: { self },
            firstRunAction: firstRun,
            appUpdateAction: appUpdate
        )
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
