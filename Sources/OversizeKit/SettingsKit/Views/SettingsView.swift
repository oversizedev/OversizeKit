//
// Copyright © 2023 Alexander Romanov
// SettingsView.swift
//

import OversizeLocalizable
import OversizeResources
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
public struct SettingsView<AppSection: View, HeadSection: View>: View {
    @Environment(Router<SettingsScreen>.self) var router
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @Environment(\.theme) var theme: ThemeSettings
    @StateObject var settingsService = SettingsService()

    let appSection: AppSection
    let headSection: HeadSection

    public init(
        @ViewBuilder appSection: () -> AppSection,
        @ViewBuilder headSection: () -> HeadSection
    ) {
        self.appSection = appSection()
        self.headSection = headSection()
    }

    public var body: some View {
        Page(L10n.Settings.title) {
            #if os(iOS)
            iOSSettings
            #else
            macSettings
            #endif
        }.backgroundSecondary()
    }
}

// iOS Settings
#if os(iOS)
extension SettingsView {
    private var iOSSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            if let stoteKit = FeatureFlags.app.storeKit {
                if stoteKit {
                    SectionView {
                        PrmiumBannerRow()
                    }
                    .surfaceContentMargins(.zero)
                }
            }
            Group {
                app
                help
                about
            }
            .surfaceContentRowMargins()
        }
    }
}
#endif

extension SettingsView {
    private var head: some View {
        SectionView {
            headSection
        }
    }

    private var app: some View {
        SectionView("General") {
            VStack(spacing: .zero) {
                if FeatureFlags.app.apperance.valueOrFalse {
                    Row(L10n.Settings.apperance) {
                        router.move(.appearance)
                    } leading: {
                        apperanceSettingsIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.сloudKit.valueOrFalse || FeatureFlags.app.healthKit.valueOrFalse {
                    Row(L10n.Title.synchronization) {
                        router.move(.sync)
                    } leading: {
                        cloudKitIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.secure.faceID.valueOrFalse
                    || FeatureFlags.secure.lookscreen.valueOrFalse
                    || FeatureFlags.secure.CVVCodes.valueOrFalse
                    || FeatureFlags.secure.alertSecureCodes.valueOrFalse
                    || FeatureFlags.secure.blurMinimize.valueOrFalse
                    || FeatureFlags.secure.bruteForceSecure.valueOrFalse
                    || FeatureFlags.secure.photoBreaker.valueOrFalse
                {
                    Row(L10n.Security.title) {
                        router.move(.security)
                    } leading: {
                        securityIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.sounds.valueOrFalse || FeatureFlags.app.vibration.valueOrFalse {
                    Row(soundsAndVibrationTitle) {
                        router.move(.soundAndVibration)
                    } leading: {
                        FeatureFlags.app.sounds.valueOrFalse ? soundIcon.icon() : vibrationIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.notifications.valueOrFalse {
                    Row(L10n.Settings.notifications) {
                        router.move(.notifications)
                    } leading: {
                        notificationsIcon.icon()
                    }
                    .rowArrow()
                }

                appSection
            }
        }
    }

    var apperanceSettingsIcon: Image {
        switch iconStyle {
        case .line:
            Image.Design.paintingPalette
        case .fill:
            Image.Design.PaintingPalette.fill
        case .twoTone:
            Image.Design.PaintingPalette.twoTone
        }
    }

    var cloudKitIcon: Image {
        switch iconStyle {
        case .line:
            Image.Weather.cloud2
        case .fill:
            Image.Weather.Cloud.Square.fill
        case .twoTone:
            Image.Weather.Cloud.Square.twoTone
        }
    }

    var securityIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.lock
        case .fill:
            Image.Base.Lock.fill
        case .twoTone:
            Image.Base.Lock.TwoTone.fill
        }
    }

    var soundIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.volumeUp
        case .fill:
            Image.Base.VolumeUp.fill
        case .twoTone:
            Image.Base.VolumeUp.TwoTone.fill
        }
    }

    var vibrationIcon: Image {
        switch iconStyle {
        case .line:
            Image.Mobile.vibration
        case .fill:
            Image.Mobile.Vibration.fill
        case .twoTone:
            Image.Mobile.Vibration.twoTone
        }
    }

    var notificationsIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.notification
        case .fill:
            Image.Base.Notification.fill
        case .twoTone:
            Image.Base.Notification.TwoTone.fill
        }
    }

    // App Store Review
    private var help: some View {
        SectionView(L10n.Settings.supportSection) {
            VStack(alignment: .leading) {
                Row("Get help") {
                    #if os(iOS)
                    router.present(.support, detents: [.medium])
                    #endif
                } leading: {
                    helpIcon.icon()
                }
                .rowArrow()
                .buttonStyle(.row)

                Row("Send feedback") {
                    #if os(iOS)
                    router.present(.feedback, detents: [.medium])
                    #endif
                } leading: {
                    chatIcon.icon()
                }
                .rowArrow()
                .buttonStyle(.row)
            }
        }
    }

    var heartIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.heart
        case .fill:
            Image.Base.Heart.fill
        case .twoTone:
            Image.Base.Heart.TwoTone.fill
        }
    }

    var mailIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.message
        case .fill:
            Image.Base.Message.fill
        case .twoTone:
            Image.Base.Message.TwoTone.fill
        }
    }

    var chatIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.chat
        case .fill:
            Image.Base.Chat.fill
        case .twoTone:
            Image.Base.Chat.twoTone
        }
    }

    var infoIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.Info.circle
        case .fill:
            Image.Base.Info.Circle.fill
        case .twoTone:
            Image.Base.Info.Circle.twoTone
        }
    }

    var oversizeIcon: Image {
        switch iconStyle {
        case .line:
            Image.Brands.oversize
        case .fill:
            Image.Brands.Oversize.fill
        case .twoTone:
            Image.Brands.Oversize.TwoTone.fill
        }
    }

    var helpIcon: Image {
        switch iconStyle {
        case .line:
            Image.Alert.Help.circle
        case .fill:
            Image.Alert.Help.Circle.fill
        case .twoTone:
            Image.Alert.Help.Circle.twoTone
        }
    }

    private var about: some View {
        SectionView {
            VStack(spacing: .zero) {
                Row(L10n.Settings.about) {
                    router.move(.about)
                } leading: {
                    infoIcon.icon()
                }
                .rowArrow()
            }
            .buttonStyle(.row)
        }
    }

    var soundsAndVibrationTitle: String {
        if FeatureFlags.app.sounds.valueOrFalse, FeatureFlags.app.vibration.valueOrFalse {
            L10n.Settings.soundsAndVibration
        } else if FeatureFlags.app.sounds.valueOrFalse, !FeatureFlags.app.vibration.valueOrFalse {
            L10n.Settings.sounds
        } else if !FeatureFlags.app.sounds.valueOrFalse, FeatureFlags.app.vibration.valueOrFalse {
            L10n.Settings.vibration
        } else {
            ""
        }
    }
}

extension SettingsView {
    #if os(macOS)
    private var macSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            if let stoteKit = FeatureFlags.app.storeKit {
                if stoteKit {
                    SectionView {
                        PrmiumBannerRow()
                    }
                    .surfaceContentMargins(.zero)
                }
            }
            SectionView("Feedback") {
                FeedbackViewRows()
            }
            .surfaceContentRowMargins()
        }
    }
    #endif
}

public extension SettingsView where HeadSection == EmptyView {
    init(@ViewBuilder appSection: () -> AppSection) {
        self.init(appSection: appSection, headSection: { EmptyView() })
    }
}
