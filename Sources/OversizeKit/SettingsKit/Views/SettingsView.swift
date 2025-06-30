//
// Copyright © 2023 Alexander Romanov
// SettingsView.swift
//

import OversizeLocalizable
import OversizeNavigation
import OversizeResources
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
public struct SettingsView<AppSection: View, HeadSection: View>: View {
    @Environment(\.navigator) var navigator
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
        NavigationLayoutView(L10n.Settings.title) {
            #if os(iOS)
            iOSSettings
            #else
            macSettings
            #endif
        } background: {
            Color.backgroundSecondary
        }
        .toolbarTitleDisplayMode(.inline)
    }
}

// iOS Settings
#if os(iOS)
extension SettingsView {
    private var iOSSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            if let storeKit = FeatureFlags.app.storeKit {
                if storeKit {
                    SectionView {
                        PremiumBannerRow()
                    }
                    .surfaceContentMargins(.zero)
                }
            }
            Group {
                app
                #if DEBUG
                debug
                #endif
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

    @available(iOS 15.0, *)
    private var app: some View {
        SectionView("General") {
            VStack(spacing: .zero) {
                if FeatureFlags.app.appearance.valueOrFalse {
                    Row(L10n.Settings.apperance) {
                        navigator.navigate(to: SettingsDestinations.appearance)
                    } leading: {
                        appearanceSettingsIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.сloudKit.valueOrFalse || FeatureFlags.app.healthKit.valueOrFalse {
                    Row(L10n.Title.synchronization) {
                        navigator.navigate(to: SettingsDestinations.sync)
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
                        navigator.navigate(to: SettingsDestinations.security)

                    } leading: {
                        securityIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.sounds.valueOrFalse || FeatureFlags.app.vibration.valueOrFalse {
                    Row(soundsAndVibrationTitle) {
                        navigator.navigate(to: SettingsDestinations.soundAndVibration)

                    } leading: {
                        FeatureFlags.app.sounds.valueOrFalse ? soundIcon.icon() : vibrationIcon.icon()
                    }
                    .rowArrow()
                }

                if FeatureFlags.app.notifications.valueOrFalse {
                    Row(L10n.Settings.notifications) {
                        navigator.navigate(to: SettingsDestinations.notifications)

                    } leading: {
                        notificationsIcon.icon()
                    }
                    .rowArrow()
                }

                appSection
            }
        }
    }

    @available(macOS 13.0, *)
    private var macGeneral: some View {
        appSection
    }

    var appearanceSettingsIcon: Image {
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
                    navigator.navigate(to: SettingsDestinations.support)

                    #endif
                } leading: {
                    helpIcon.icon()
                }
                .rowArrow()
                .buttonStyle(.row)

                Row("Send feedback") {
                    #if os(iOS)
                    navigator.navigate(to: SettingsDestinations.feedback)

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

    #if DEBUG
    var debugIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.game
        case .fill:
            Image.Base.Game.fill
        case .twoTone:
            Image.Base.Game.twoTone
        }
    }
    #endif

    #if DEBUG
    var debugInfoIcon: Image {
        switch iconStyle {
        case .line:
            Image.Base.document
        case .fill:
            Image.Base.Document.fill
        case .twoTone:
            Image.Base.Document.twoTone
        }
    }
    #endif

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

    #if DEBUG
    private var debug: some View {
        SectionView {
            VStack(spacing: .zero) {
                Row("Debug") {
                    navigator.navigate(to: SettingsDestinations.debugMenu)
                } leading: {
                    debugIcon.icon()
                }
                .rowArrow()

                Row("Information") {
                    navigator.navigate(to: SettingsDestinations.debugInfo)
                } leading: {
                    debugInfoIcon.icon()
                }
                .rowArrow()
            }
            .buttonStyle(.row)
        }
    }
    #endif

    private var about: some View {
        SectionView {
            VStack(spacing: .zero) {
                Row(L10n.Settings.about) {
                    navigator.navigate(to: SettingsDestinations.about)
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
    @available(macOS 13.0, *)
    private var macSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            if let storeKit = FeatureFlags.app.storeKit {
                if storeKit {
                    SectionView {
                        PremiumBannerRow()
                    }
                    .surfaceContentMargins(.zero)
                }
            }

            macGeneral

            #if DEBUG
            debug
            #endif

            SectionView("Feedback") {
                FeedbackViewRows()
            }
            .surfaceContentRowMargins()
        }
    }
}

public extension SettingsView where HeadSection == EmptyView {
    init(@ViewBuilder appSection: () -> AppSection) {
        self.init(appSection: appSection, headSection: { EmptyView() })
    }
}
