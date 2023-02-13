//
// Copyright © 2022 Alexander Romanov
// iCloudSettingsView.swift
//

import OversizeLocalizable
import OversizeServices

import OversizeUI
import SwiftUI

// swiftlint:disable line_length type_name
#if os(iOS)
    public struct iCloudSettingsView: View { // Synchronization
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @StateObject var settingsService = SettingsService()
        @State var offset = CGPoint(x: 0, y: 0)

        public var body: some View {
            PageView(L10n.Title.synchronization) {
                iOSSettings
            }
            .leadingBar {
                if !isPortrait, verticalSizeClass == .regular {
                    EmptyView()
                } else {
                    BarButton(.back)
                }
            }
            .backgroundSecondary()
        }
    }

    extension iCloudSettingsView {
        private var iOSSettings: some View {
            VStack(alignment: .center, spacing: 0) {
                soundsAndVibrations
            }
        }
    }

    extension iCloudSettingsView {
        private var soundsAndVibrations: some View {
            SectionView {
                VStack(spacing: .zero) {
                    if FeatureFlags.app.сloudKit.valueOrFalse {
                        Switch(isOn: $settingsService.cloudKitEnabled) {
                            Row(L10n.Settings.iCloudSync) {
                                Icon(.cloud)
                            }
                            .premium()
                            .onPremiumTap()
                        }
                    }

                    if FeatureFlags.secure.CVVCodes.valueOrFalse {
                        Switch(isOn: $settingsService.cloudKitCVVEnabled) {
                            Row(L10n.Security.iCloudSyncCVVDescriptionCloudKit,
                                subtitle: settingsService.cloudKitCVVEnabled ? L10n.Security.iCloudSyncCVVDescriptionCloudKit : L10n.Security.iCloudSyncCVVDescriptionLocal)
                                .premium()
                                .onPremiumTap()
                        }
                    }

                    if FeatureFlags.app.healthKit.valueOrFalse {
                        Switch(isOn: $settingsService.healthKitEnabled) {
                            Row("HealthKit synchronization", subtitle: "After switching on, data from the Health app will be downloaded") {
                                Icon(.heart)
                            }
                        }
                    }
                }
            }
        }
    }
#endif
