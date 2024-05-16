//
// Copyright © 2022 Alexander Romanov
// SoundsAndVibrationsSettingsView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

public struct SoundsAndVibrationsSettingsView: View {
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @StateObject var settingsService = SettingsService()

    public init() {}

    public var body: some View {
        Page(title) {
            iOSSettings
                .surfaceContentRowMargins()
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
                    Switch(isOn: $settingsService.soundsEnabled) {
                        Row(L10n.Settings.sounds) {
                            IconDeprecated(.music)
                        }
                    }
                }

                if FeatureFlags.app.vibration.valueOrFalse {
                    Switch(isOn: $settingsService.vibrationEnabled) {
                        Row(L10n.Settings.vibration) {
                            vibrationIcon.icon()
                        }
                    }
                }
            }
        }
    }

    var vibrationIcon: Image {
        switch iconStyle {
        case .line:
            return Image.Mobile.vibration
        case .fill:
            return Image.Mobile.Vibration.fill
        case .twoTone:
            return Image.Mobile.Vibration.twoTone
        }
    }
}
