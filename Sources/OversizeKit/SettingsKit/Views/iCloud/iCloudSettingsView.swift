//
// Copyright © 2022 Alexander Romanov
// iCloudSettingsView.swift
//

import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length type_name
public struct iCloudSettingsView: View { // Synchronization
    @StateObject var settingsService = SettingsService()

    public init() {}

    public var body: some View {
        NavigationLayoutView(L10n.Title.synchronization) {
            iOSSettings
                .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
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
