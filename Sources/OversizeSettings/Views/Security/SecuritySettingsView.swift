//
// Copyright © 2022 Alexander Romanov
// SecuritySettingsView.swift
//

import OversizeCraft
import OversizePrivateServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct SecuritySettingsView: View {
        @EnvironmentObject private var settingsStore: SettingsService
        private var biometricService = BiometricService.shared

        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @State var offset = CGPoint(x: 0, y: 0)

        @State var isSetPINCodeSheet: PINCodeAction?

        public init() {}

        public var body: some View {
            PageView(L10n.Security.title) {
                iOSSettings
            }
            .leadingBar {
                if !isPortrait, verticalSizeClass == .regular {
                    EmptyView()
                } else {
                    BarButton(type: .back)
                }
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
                        Row(biometricService.biometricType.rawValue, leadingType: .systemImage(biometricImageName), trallingType: .toggle(isOn:
                            Binding(get: {
                                settingsStore.biometricEnabled
                            }, set: {
                                settingsStore.biometricChange($0)
                            })))
                    }

                    if FeatureFlags.secure.lookscreen.valueOrFalse {
                        Row(L10n.Security.pinCode,
                            leadingType: .icon(.lock),
                            trallingType: .toggle(isOn:
                                Binding(get: {
                                    settingsStore.pinCodeEnabend
                                }, set: {
                                    if settingsStore.isSetedPinCode() {
                                        settingsStore.pinCodeEnabend = $0
                                    } else {
                                        isSetPINCodeSheet = .set
                                    }
                                }))).sheet(item: $isSetPINCodeSheet) { sheet in
                            SetPINCodeView(action: sheet)
                                .systemServices()
                        }

                        if settingsStore.isSetedPinCode() {
                            Row(L10n.Security.changePINCode, trallingType: .arrowIcon) {
                                isSetPINCodeSheet = .update
                            }
                        }
                    }
                }
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
//                if FeatureFlags.secure.blurMinimize.valueOrFalse {
//                    Row(L10n.Security.blurMinimize, trallingType: .toggle(isOn: $settingsStore.blurMinimizeEnabend))
//                        .premium()
//                        .onPremiumTap()
//                }

                    if FeatureFlags.secure.lookscreen.valueOrFalse {
                        Row(L10n.Security.authHistory, trallingType: .toggle(isOn: $settingsStore.authHistoryEnabend))
                            .premium()
                            .onPremiumTap()
                    }
                }
            }
        }

        private var biometricImageName: String {
            switch biometricService.biometricType {
            case .none:
                return ""

            case .touchID:
                return "touchid"

            case .faceID:
                return "faceid"
            }
        }
    }
#endif
