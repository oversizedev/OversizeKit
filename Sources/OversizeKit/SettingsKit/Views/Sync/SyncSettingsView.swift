//
// Copyright © 2022 Alexander Romanov
// SyncSettingsView.swift
//

import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

public struct SyncSettingsView: View {
    @StateObject var settingsService = SettingsService()
    @State private var showRestartWarning = false
    @State private var syncMonitor = CloudSyncMonitor()

    public init() {}

    public var body: some View {
        NavigationListLayoutView(L10n.Title.synchronization) {
            if FeatureFlags.app.сloudKit.valueOrFalse {
                ListSection {
                    Toggle(isOn: $settingsService.cloudKitEnabled) {
                        ListRow(
                            L10n.Settings.iCloudSync,
                            subtitle: title,
                            leading: {
                                icon.iconOnSurface()
                            }
                        )
                        .premium()
                    }
                    .onPremiumTap()

                } footer: {
                    if showRestartWarning {
                        Text("Changes will take effect after restarting the app")
                    }
                }

                ListSection {
                    Toggle(isOn: $settingsService.cloudKitCVVEnabled) {
                        ListRow(
                            "CVV iCloud sync",
                            leading: {
                                Icon("creditcard").iconOnSurface()
                            }
                        )
                    }
                }
            }

            if FeatureFlags.app.healthKit.valueOrFalse {
                ListSection {
                    Toggle(isOn: $settingsService.healthKitEnabled) {
                        ListRow(
                            "HealthKit synchronization",
                            subtitle: "After switching on, data from the Health app will be downloaded",
                            leading: {
                                Icon(Image.Romantic.heart)
                                    .iconOnSurface()
                            }
                        )
                    }
                }
            }
        }
        .listLayoutStyle(.insetGrouped)
        .onChange(of: settingsService.cloudKitEnabled) { _, _ in
            showRestartWarning = true
        }
        .task {
            syncMonitor.start()
        }
    }

    private var title: String? {
        if settingsService.cloudKitEnabled {
            switch syncMonitor.status {
            case .idle:
                "iCloud is up to date"
            case let .syncing(message):
                message
            case .success:
                "Sync completed"
            case let .failed(message):
                "Sync failed: \(message)"
            }
        } else {
            nil
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch syncMonitor.status {
        case .idle:
            Icon("icloud")
                .font(.system(size: 16, weight: .semibold))
        case .syncing:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                Icon("arrow.triangle.2.circlepath")
                    .symbolEffect(.rotate)
            } else {
                Icon("arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
            }
        case .success:
            Icon("checkmark.icloud.fill")
                .font(.system(size: 16, weight: .semibold))
        case .failed:
            Icon("exclamationmark.icloud.fill")
                .font(.system(size: 16, weight: .semibold))
        }
    }
}

#Preview {
    SyncSettingsView()
}
