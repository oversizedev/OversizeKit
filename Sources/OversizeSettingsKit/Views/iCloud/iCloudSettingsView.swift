//
// Copyright © 2022 Alexander Romanov
// iCloudSettingsView.swift
//

import OversizeLocalizable
import OversizeServices
import OversizeSettingsService
import OversizeStoreService
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
                    BarButton(type: .back)
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
                        Row(L10n.Settings.iCloudSync, trallingType: .toggle(isOn: $settingsService.cloudKitEnabled))
                            .premium()
                            .onPremiumTap()
                    }

                    if FeatureFlags.secure.CVVCodes.valueOrFalse {
                        Row(L10n.Security.iCloudSyncCVV,
                            subtitle: settingsService.cloudKitCVVEnabled ? L10n.Security.iCloudSyncCVVDescriptionCloudKit : L10n.Security.iCloudSyncCVVDescriptionLocal,
                            trallingType: .toggle(isOn: $settingsService.cloudKitCVVEnabled))
                            .premium()
                            .onPremiumTap()
                    }

                    if FeatureFlags.app.healthKit.valueOrFalse {
                        Row("HealthKit synchronization", trallingType: .toggle(isOn: $settingsService.healthKitEnabled))
                        // .premium()
                        // .onPremiumTap()
                    }
                }
            }
        }
    }
#endif
