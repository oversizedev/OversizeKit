//
// Copyright © 2022 Alexander Romanov
// SoundsAndVibrationsSettingsView.swift
//

import OversizeCraft
import OversizePrivateServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct SoundsAndVibrationsSettingsView: View {
        @EnvironmentObject var settingsStore: SettingsService
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @State var offset = CGPoint(x: 0, y: 0)

        var title: String {
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
                        Row(L10n.Settings.sounds, leadingType: .icon(.music), trallingType: .toggle(isOn: $settingsStore.soundsEnabled))
                    }

                    if FeatureFlags.app.vibration.valueOrFalse {
                        Row(L10n.Settings.vibration, leadingType: .icon(.radio), trallingType: .toggle(isOn: $settingsStore.vibrationEnabled))
                    }
                }
            }
        }
    }
#endif
