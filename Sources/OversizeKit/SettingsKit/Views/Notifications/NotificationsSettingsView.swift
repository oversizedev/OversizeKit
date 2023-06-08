//
// Copyright © 2022 Alexander Romanov
// NotificationsSettingsView.swift
//

import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct NotificationsSettingsView: View {
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @StateObject var settingsService = SettingsService()
        @State var offset = CGPoint(x: 0, y: 0)

        public var body: some View {
            PageView(L10n.Settings.notifications) {
                soundsAndVibrations
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

    extension NotificationsSettingsView {
        private var soundsAndVibrations: some View {
            SectionView {
                VStack(spacing: .zero) {
                    Switch(L10n.Settings.notifications, isOn: $settingsService.notificationEnabled)
                }
            }
        }
    }
#endif
