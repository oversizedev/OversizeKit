//
// Copyright © 2023 Alexander Romanov
// Launcher.swift
//

import NavigatorUI
import OversizeCore
import OversizeLocalizable
import OversizeNavigation
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
        appUpdateAction: ((String, String?) -> Void)? = nil
    ) {
        self.content = content()
        _viewModel = StateObject(wrappedValue: LauncherViewModel(
            firstRunAction: firstRunAction,
            appUpdateAction: appUpdateAction
        ))
    }

    public var body: some View {
        contentView
            .appLaunchCover(item: $viewModel.activeFullScreenSheet) {
                fullScreenCover(sheet: $0)
                    .coreServices()
                    #if os(macOS)
                    .frame(width: viewModel.contentType == .onboarding ? 840 : 500, height: 672)
                    #endif
            }
            .onChange(of: viewModel.appStateService.isCompletedOnboarding) { _, isCompletedOnboarding in
                viewModel.onCompeteOnboarding(isCompletedOnboarding)
            }
            .onChange(of: scenePhase) { _, value in
                viewModel.onScenePhaseChange(value)
            }
            .presentationHUDRoot()
            .coreServices()
            .task(viewModel.onAppear)
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.contentType {
        case .content:
            if viewModel.isShowLockscreen {
                lockscreenView
            } else {
                content
                    .task {
                        await viewModel.reviewService.launchEvent()
                        await viewModel.launcherSheetsCheck()
                    }
            }
        case .onboarding:
            onboarding
        }
    }

    @ViewBuilder
    private func fullScreenCover(sheet: LauncherViewModel.FullScreenSheet) -> some View {
        switch sheet {
        case .payWall:
            ManagedNavigationStack {
                StoreInstructionsView(specialOfferMode: true)
            }
        case .rate:
            ManagedNavigationStack {
                RateAppScreen()
            }
        case let .specialOffer(event):
            ManagedNavigationStack {
                StoreSpecialOfferView(event: event)
            }
        case let .whatsNew(version):
            ManagedNavigationStack {
                AppUpdate.build(input: .init(version: version))
            }
        }
    }

    private var lockscreenView: some View {
        LockscreenView(
            pinCode: $viewModel.pinCodeField,
            state: $viewModel.authState,
            title: L10n.Security.enterPINCode,
            errorText: L10n.Security.invalidPIN,
            pinCodeEnabled: viewModel.settingsService.pinCodeEnabled,
            biometricEnabled: viewModel.settingsService.biometricEnabled,
            biometricType: viewModel.biometricService.biometricType
        ) {
            viewModel.checkPassword()
        } biometricAction: {
            Task {
                await viewModel.appBiometricUnlock()
            }
        }
        .task {
            if viewModel.settingsService.biometricEnabled, scenePhase != .background {
                await viewModel.appBiometricUnlock()
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
        appUpdateAction: ((String, String?) -> Void)? = nil
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
        appUpdate: ((String, String?) -> Void)? = nil
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
    func appLaunchCover<Item: Identifiable>(
        item: Binding<Item?>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
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
