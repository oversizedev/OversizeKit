//
// Copyright © 2022 Alexander Romanov
// SoundsAndVibrationsSettingsView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeSettingsService
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct SoundsAndVibrationsSettingsView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @State var offset = CGPoint(x: 0, y: 0)
        @StateObject var settingsService = SettingsService()

        public var body: some View {
            PageView(title) {
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

        private var title: String {
            if FeatureFlags.app.sounds.valueOrFalse, FeatureFlags.app.vibration.valueOrFalse {
                return L10n.Settings.soundsAndVibration
            } else if FeatureFlags.app.sounds.valueOrFalse, !FeatureFlags.app.vibration.valueOrFalse {
                return L10n.Settings.sounds
            } else if !FeatureFlags.app.sounds.valueOrFalse, FeatureFlags.app.vibration.valueOrFalse {
                return L10n.Settings.vibration
            } else {
                return ""
            }
        }
    }

    extension SoundsAndVibrationsSettingsView {
        private var iOSSettings: some View {
            VStack(alignment: .center, spacing: 0) {
                soundsAndVibrations
            }
        }
    }

    extension SoundsAndVibrationsSettingsView {
        private var soundsAndVibrations: some View {
            SectionView {
                VStack(spacing: .zero) {
                    if FeatureFlags.app.sounds.valueOrFalse {
                        Row(L10n.Settings.sounds, leadingType: .icon(.music), trallingType: .toggle(isOn: $settingsService.soundsEnabled))
                    }

                    if FeatureFlags.app.vibration.valueOrFalse {
                        Row(L10n.Settings.vibration, leadingType: .icon(.radio), trallingType: .toggle(isOn: $settingsService.vibrationEnabled))
                    }
                }
            }
        }
    }
#endif
