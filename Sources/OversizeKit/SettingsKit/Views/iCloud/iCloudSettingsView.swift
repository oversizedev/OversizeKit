//
// Copyright © 2022 Alexander Romanov
// iCloudSettingsView.swift
//

import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length type_name

public struct iCloudSettingsView: View { // Synchronization
    @StateObject var settingsService = SettingsService()

    public init() {}

    public var body: some View {
        Page(L10n.Title.synchronization) {
            iOSSettings
                .surfaceContentRowMargins()
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
                            Image.Weather.Cloud.square.icon()
                        }
                        .premium()
                    }
                    .onPremiumTap()
                }

                if FeatureFlags.secure.CVVCodes.valueOrFalse {
                    Switch(isOn: $settingsService.cloudKitCVVEnabled) {
                        Row(L10n.Security.iCloudSyncCVVDescriptionCloudKit,
                            subtitle: settingsService.cloudKitCVVEnabled ? L10n.Security.iCloudSyncCVVDescriptionCloudKit : L10n.Security.iCloudSyncCVVDescriptionLocal)
                        {
                            Image.Security.cloudLock
                                .icon()
                                .frame(width: 24, height: 24)
                        }
                        .premium()
                        .onPremiumTap()
                    }
                }

                if FeatureFlags.app.healthKit.valueOrFalse {
                    Switch(isOn: $settingsService.healthKitEnabled) {
                        Row("HealthKit synchronization", subtitle: "After switching on, data from the Health app will be downloaded") {
                            Image.Romantic.heart.icon()
                        }
                    }
                }
            }
        }
    }
}
