//
// Copyright © 2022 Alexander Romanov
// SecuritySettingsView.swift
//

import FactoryKit
import NavigatorUI
import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length

public struct SecuritySettingsView: View {
    @Injected(\.biometricService) var biometricService
    @Environment(\.navigator) var navigator
    @StateObject var settingsService = SettingsService()

    let min: [Double] = [60, 120, 300, 600]
    public init() {}

    public var body: some View {
        NavigationLayoutView(L10n.Security.title) {
            iOSSettings
                .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
    }
}

extension SecuritySettingsView {
    private var iOSSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            faceID

            additionally
        }
    }
}

extension SecuritySettingsView {
    private var faceID: some View {
        SectionView(L10n.Settings.entrance) {
            VStack(spacing: .zero) {
                if FeatureFlags.secure.faceID.valueOrFalse, biometricService.checkIfBioMetricAvailable() {
                    Switch(isOn:
                        Binding(get: {
                            settingsService.biometricEnabled
                        }, set: {
                            biometricChange(state: $0)
                        })) {
                            Row(biometricService.biometricType.rawValue) {
                                Image(systemName: biometricImageName)
                                    .foregroundColor(Color.onBackgroundPrimary)
                                    #if os(macOS)
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 24, height: 24, alignment: .center)
                                    #else
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(width: 24, height: 24, alignment: .center)
                                    #endif
                            }
                        }
                }

                if FeatureFlags.secure.lookscreen.valueOrFalse {
                    Switch(isOn:
                        Binding(get: {
                            settingsService.pinCodeEnabled
                        }, set: {
                            if settingsService.isSetPinCode() {
                                settingsService.pinCodeEnabled = $0
                            } else {
                                navigator.navigate(to: SettingsDestinations.setPINCode)
                            }
                        })) {
                            Row(L10n.Security.pinCode) {
                                Image.Security.lock.icon()
                            }
                        }

                    if settingsService.isSetPinCode() {
                        Row(L10n.Security.changePINCode) {
                            navigator.navigate(to: SettingsDestinations.updatePINCode)
                        }
                        .navigatable()
                    }
                }
            }
        }
    }

    private func biometricChange(state: Bool) {
        Task {
            await settingsService.biometricChange(state)
        }
    }

    private var additionally: some View {
        SectionView(L10n.Settings.additionally) {
            VStack(spacing: .zero) {
//                if FeatureFlags.secure.lockscreen.valueOrFalse {
//                    Row(L10n.Security.inactiveAskPassword, trallingType: .toggle(isOn: $settingsStore.askPasswordWhenInactiveEnabend))
//                }
//
//                if FeatureFlags.secure.lockscreen.valueOrFalse {
//                    Row(L10n.Security.minimizeAskPassword, trallingType: .toggle(isOn: $settingsStore.askPasswordAfterMinimizeEnabend))
//                }

//                if FeatureFlags.secure.CVVCodes.valueOrFalse {
//                    Row(L10n.Security.faceIDForCVV, trallingType: .toggle(isOn: $settingsStore.biometricWhenGetCVVEnabend))
//                }

//                if FeatureFlags.secure.bruteForceSecure.valueOrFalse {
//                    Row(L10n.Security.bruteForceSecurity, trallingType: .toggle(isOn: $settingsStore.deleteDataIfBruteForceEnabled))
//                        .premium()
//                        .onPremiumTap()
//                }

//                if FeatureFlags.secure.lockscreen.valueOrFalse {
//                    Row(L10n.Security.alertPINCode, trallingType: .toggle(isOn: $settingsStore.alertPINCodeEnabled))
//                }
//
//                if FeatureFlags.secure.photoBreaker.valueOrFalse {
//                    Row(L10n.Security.photoBreaker, trallingType: .toggle(isOn: $settingsStore.photoBreakerEnabend))
//                }
//
//                if FeatureFlags.secure.lockscreen.valueOrFalse {
//                    Row(L10n.Security.facedownLock, trallingType: .toggle(isOn: $settingsStore.lookScreenDownEnabend))
//                }
//
                if FeatureFlags.secure.blurMinimize.valueOrFalse {
                    Switch(isOn: $settingsService.blurMinimizeEnabled) {
                        Row(L10n.Security.blurMinimize)
                            .premium()
                    }
                    .onPremiumTap()
                }

                if FeatureFlags.secure.lookscreen.valueOrFalse {
                    Switch(isOn: $settingsService.fastEnter) {
                        Row("Fast enter")
                    }
                }
                if settingsService.fastEnter {
                    Row("Time to enter", trailing: {
                        Picker("", selection: $settingsService.appLockTimeout) {
                            ForEach(0 ..< min.count, id: \.self) { // Non-constant range: argument must be an integer literal
                                let min = Int(self.min[$0] / 60)

                                Text("\(min) \(OversizeLocalizable.L10n.Time.mins)")
                                    .tag(self.min[$0])
                            }
                        }
                        #if !os(macOS)
                        .pickerStyle(.navigationLink)
                        #endif
                        .labelsHidden()
                        .clipped()
                    })
                    .navigatable()
                }

//                    if FeatureFlags.secure.lockscreen.valueOrFalse {
//                        Row(L10n.Security.authHistory, trallingType: .toggle(isOn: $settingsService.authHistoryEnabend))
//                            .premium()
//                            .onPremiumTap()
//                    }
            }
        }
    }

    private var biometricImageName: String {
        switch biometricService.biometricType {
        case .none:
            ""
        case .touchID:
            "touchid"
        case .faceID:
            "faceid"
        case .opticID:
            "opticid"
        }
    }
}

#Preview {
    SecuritySettingsView()
        .coreServices()
}
