//
// Copyright © 2022 Alexander Romanov
// SecuritySettingsView.swift
//

import Factory
import OversizeLocalizable
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length

public struct SecuritySettingsView: View {
    @Injected(\.biometricService) var biometricService
    @Environment(Router<SettingsScreen>.self) var router
    @StateObject var settingsService = SettingsService()

    public init() {}

    public var body: some View {
        Page(L10n.Security.title) {
            iOSSettings
                .surfaceContentRowMargins()
        }
        .backgroundSecondary()
    }
}

extension SecuritySettingsView {
    private var iOSSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            faceID

            // additionally
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
                        })
                    ) {
                        Row(biometricService.biometricType.rawValue) {
                            Image(systemName: biometricImageName)
                                .foregroundColor(Color.onBackgroundPrimary)
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                    }
                }

                if FeatureFlags.secure.lookscreen.valueOrFalse {
                    Switch(isOn:
                        Binding(get: {
                            settingsService.pinCodeEnabend
                        }, set: {
                            if settingsService.isSetedPinCode() {
                                settingsService.pinCodeEnabend = $0
                            } else {
                                router.present(.setPINCode)
                            }
                        })
                    ) {
                        Row(L10n.Security.pinCode) {
                            Image.Security.lock.icon()
                        }
                    }

                    if settingsService.isSetedPinCode() {
                        Row(L10n.Security.changePINCode) {
                            router.present(.updatePINCode)
                        }
                        .rowArrow()
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
//                if FeatureFlags.secure.lookscreen.valueOrFalse {
//                    Row(L10n.Security.inactiveAskPassword, trallingType: .toggle(isOn: $settingsStore.askPasswordWhenInactiveEnabend))
//                }
//
//                if FeatureFlags.secure.lookscreen.valueOrFalse {
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

//                if FeatureFlags.secure.lookscreen.valueOrFalse {
//                    Row(L10n.Security.alertPINCode, trallingType: .toggle(isOn: $settingsStore.alertPINCodeEnabled))
//                }
//
//                if FeatureFlags.secure.photoBreaker.valueOrFalse {
//                    Row(L10n.Security.photoBreaker, trallingType: .toggle(isOn: $settingsStore.photoBreakerEnabend))
//                }
//
//                if FeatureFlags.secure.lookscreen.valueOrFalse {
//                    Row(L10n.Security.facedownLock, trallingType: .toggle(isOn: $settingsStore.lookScreenDownEnabend))
//                }
//
                if FeatureFlags.secure.blurMinimize.valueOrFalse {
                    Switch(isOn: $settingsService.blurMinimizeEnabend) {
                        Row(L10n.Security.blurMinimize)
                            .premium()
                    }
                    .onPremiumTap()
                }

//                    if FeatureFlags.secure.lookscreen.valueOrFalse {
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
