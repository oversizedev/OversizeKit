//
// Copyright © 2022 Alexander Romanov
// NotificationsSettingsView.swift
//

import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length

public struct NotificationsSettingsView: View {
    @StateObject var settingsService = SettingsService()

    public init() {}

    public var body: some View {
        NavigationPageView(L10n.Settings.notifications) {
            soundsAndVibrations
                .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
    }
}

extension NotificationsSettingsView {
    private var soundsAndVibrations: some View {
        SectionView {
            VStack(spacing: .zero) {
                Switch(L10n.Settings.notifications, isOn: $settingsService.notificationEnabled)
            }
        }
    }
}
