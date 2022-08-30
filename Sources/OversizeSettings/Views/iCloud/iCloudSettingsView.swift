//
// Copyright © 2022 Alexander Romanov
// iCloudSettingsView.swift
//

import OversizeCraft
import OversizePrivateServices
import OversizeStore
import OversizeUI
import SwiftUI

// swiftlint:disable line_length type_name
#if os(iOS)
    public struct iCloudSettingsView: View {
        @EnvironmentObject var settingsStore: SettingsService
        @EnvironmentObject var productsStore: StoreKitLegacyProductsService
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
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
                    Row(L10n.Settings.iCloudSync, trallingType: .toggle(isOn: $settingsStore.cloudKitEnabled))
                        .premium()
                        .onPremiumTap()

                    if FeatureFlags.secure.CVVCodes.valueOrFalse {
                        Row(L10n.Security.iCloudSyncCVV,
                            subtitle: settingsStore.cloudKitCVVEnabled ? L10n.Security.iCloudSyncCVVDescriptionCloudKit : L10n.Security.iCloudSyncCVVDescriptionLocal,
                            trallingType: .toggle(isOn: $settingsStore.cloudKitCVVEnabled))
                            .premium()
                            .onPremiumTap()
                    }
                }
            }
        }
    }
#endif
