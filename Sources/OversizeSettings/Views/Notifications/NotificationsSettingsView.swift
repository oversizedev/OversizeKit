//
// Copyright © 2022 Alexander Romanov
// NotificationsSettingsView.swift
//

import OversizeCraft
import OversizePrivateServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct NotificationsSettingsView: View {
        @EnvironmentObject var settingsStore: SettingsService
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @State var offset = CGPoint(x: 0, y: 0)

        public var body: some View {
            iOSSettings
                .navigationBarHidden(true)
        }
    }

    extension NotificationsSettingsView {
        private var iOSSettings: some View {
            VStack(alignment: .center, spacing: 0) {
                soundsAndVibrations
            }
            .scrollWithNavigationBar(L10n.Settings.notifications, style: .fixed($offset), background: Color.backgroundSecondary) {
                BarButton(type: .backAction(action: { presentationMode.wrappedValue.dismiss() }))
            } trailingBar: {} bottomBar: {}
            .background(Color.backgroundSecondary.ignoresSafeArea(.all))
        }
    }

    extension NotificationsSettingsView {
        private var soundsAndVibrations: some View {
            SectionView {
                VStack(spacing: .zero) {
                    Row(L10n.Settings.notifications, trallingType: .toggle(isOn: $settingsStore.notificationEnabled))
                }
            }
        }
    }
#endif
