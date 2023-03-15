//
// Copyright © 2023 Alexander Romanov
// SettingsView.swift
//

import OversizeLocalizable
import OversizeResources
import OversizeServices

import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct SettingsView<AppSection: View, HeadSection: View>: View {
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.iconStyle) var iconStyle: IconStyle
        @Environment(\.theme) var theme: ThemeSettings
        @StateObject var settingsService = SettingsService()
        @EnvironmentObject var hudState: HUD

        let appSection: AppSection
        let headSection: HeadSection

        @State private var offset = CGPoint(x: 0, y: 0)
        @State private var isPortrait = false
        @State private var isShowSupport = false
        @State private var isShowFeedback = false

        var isShowArrow: Bool {
            #if os(iOS)
                if !isPortrait, verticalSizeClass == .regular {
                    return false
                } else {
                    return true
                }
            #else
                return true

            #endif
        }

        public init(@ViewBuilder appSection: () -> AppSection,
                    @ViewBuilder headSection: () -> HeadSection)
        {
            self.appSection = appSection()
            self.headSection = headSection()
        }

        public var body: some View {
            #if os(iOS)

                Group {
                    if !isPortrait, verticalSizeClass == .regular {
                        Group {
                            PageView(L10n.Settings.title) {
                                iOSSettings
                            }.backgroundSecondary()

                            AppearanceSettingView()
                        }
                        .navigationable()
                        .navigationViewStyle(DoubleColumnNavigationViewStyle())
                    } else {
                        Group {
                            PageView(L10n.Settings.title) {
                                iOSSettings
                            }
                            .backgroundSecondary()
                        }
                        .navigationable()
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    setOrientation()
                }
                .onAppear {
                    setOrientation()
                }
                .portraitMode(isPortrait)

            #else
                macSettings

            #endif
        }

        func setOrientation() {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            isPortrait = scene.interfaceOrientation.isPortrait
        }
    }
#endif

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
                        .surfaceContentInsets(.zero)
                    }
                }
                Group {
                    app
                    help
                    about
                }
                .surfaceContentRowInsets()
            }
        }
    }
#endif

#if os(iOS)
    // Sections
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
                        NavigationLink(destination: AppearanceSettingView()
                        ) {
                            Row(L10n.Settings.apperance) {
                                apperanceSettingsIcon
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.сloudKit.valueOrFalse || FeatureFlags.app.healthKit.valueOrFalse {
                        NavigationLink(destination: iCloudSettingsView()
                        ) {
                            Row(L10n.Title.synchronization) {
                                cloudKitIcon
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.secure.faceID.valueOrFalse
                        || FeatureFlags.secure.lookscreen.valueOrFalse
                        || FeatureFlags.secure.CVVCodes.valueOrFalse
                        || FeatureFlags.secure.alertSecureCodes.valueOrFalse
                        || FeatureFlags.secure.blurMinimize.valueOrFalse
                        || FeatureFlags.secure.bruteForceSecure.valueOrFalse
                        || FeatureFlags.secure.photoBreaker.valueOrFalse
                    {
                        NavigationLink(destination: SecuritySettingsView()
                        ) {
                            Row(L10n.Security.title) {
                                securityIcon
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.sounds.valueOrFalse || FeatureFlags.app.vibration.valueOrFalse {
                        NavigationLink(destination: SoundsAndVibrationsSettingsView()
                        ) {
                            Row(soundsAndVibrationTitle) {
                                FeatureFlags.app.sounds.valueOrFalse ? soundIcon : vibrationIcon
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.notifications.valueOrFalse {
                        NavigationLink(destination: NotificationsSettingsView()
                        ) {
                            Row(L10n.Settings.notifications) {
                                notificationsIcon
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    appSection
                }
            }
        }

        var apperanceSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Design.brush
            case .solid:
                return Icon.Solid.Design.brush
            case .duotone:
                return Icon.Duotone.Design.brush
            }
        }

        var cloudKitIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Weather.cloudy02
            case .solid:
                return Icon.Solid.Weather.cloudy02
            case .duotone:
                return Icon.Duotone.Weather.cloudy02
            }
        }

        var securityIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.lock
            case .solid:
                return Icon.Solid.UserInterface.lock
            case .duotone:
                return Icon.Duotone.UserInterface.lock
            }
        }

        var soundIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.MediaControls.musicalNote02
            case .solid:
                return Icon.Solid.MediaControls.musicalNote02
            case .duotone:
                return Icon.Duotone.MediaControls.musicalNote02
            }
        }

        var vibrationIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Weather.windy
            case .solid:
                return Icon.Solid.Weather.windy
            case .duotone:
                return Icon.Duotone.Weather.windy
            }
        }

        var notificationsIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.bell
            case .solid:
                return Icon.Solid.UserInterface.bell
            case .duotone:
                return Icon.Duotone.UserInterface.bell
            }
        }

        // App Store Review
        private var help: some View {
            SectionView(L10n.Settings.supportSection) {
                VStack(alignment: .leading) {
                    Row("Get help") {
                        isShowSupport.toggle()
                    } leading: {
                        helpIcon
                    }
                    .rowArrow(isShowArrow)

                    .buttonStyle(.row)
                    .sheet(isPresented: $isShowSupport) {
                        SupportView()
                            .presentationDetents([.medium])
                    }

                    Row("Send feedback") {
                        isShowFeedback.toggle()
                    } leading: {
                        chatIcon
                    }
                    .rowArrow(isShowArrow)

                    .buttonStyle(.row)
                    .sheet(isPresented: $isShowFeedback) {
                        FeedbackView()
                            .presentationDetents([.medium])
                    }

//
//                    // Telegramm chat
//                    if let telegramChatUrl = AppInfo.url.appTelegramChat, let id = AppInfo.app.telegramChatID, !id.isEmpty {
//                        Link(destination: telegramChatUrl) {
//                            Row(L10n.Settings.telegramChat, leadingType: .image(chatIcon), trallingType: rowType)
//                        }
//                        .buttonStyle(.row)
//                    }
                }
            }
        }

        var heartIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.heart
            case .solid:
                return Icon.Solid.UserInterface.heart
            case .duotone:
                return Icon.Duotone.UserInterface.heart
            }
        }

        var mailIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Communication.mail
            case .solid:
                return Icon.Solid.Communication.mail
            case .duotone:
                return Icon.Duotone.Communication.mail
            }
        }

        var chatIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Communication.chatDots
            case .solid:
                return Icon.Solid.Communication.chatDots
            case .duotone:
                return Icon.Duotone.Communication.chatDots
            }
        }

        var infoIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.infoCrFr
            case .solid:
                return Icon.Solid.UserInterface.infoCrFr
            case .duotone:
                return Icon.Duotone.UserInterface.infoCrFr
            }
        }

        var oversizeIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.SocialMediaandBrands.oversize
            case .solid:
                return Icon.Solid.SocialMediaandBrands.oversize
            case .duotone:
                return Icon.Duotone.SocialMediaandBrands.oversize
            }
        }

        var helpIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.questionMarkCrFr
            case .solid:
                return Icon.Solid.UserInterface.questionMarkCrFr
            case .duotone:
                return Icon.Duotone.UserInterface.questionMarkCrFr
            }
        }

        private var about: some View {
            SectionView {
                VStack(spacing: .zero) {
                    NavigationLink(destination: AboutView()) {
                        Row(L10n.Settings.about) {
                            infoIcon
                        }
                        .rowArrow(isShowArrow)
                    }
                    .buttonStyle(.row)
                }
            }
        }

        var soundsAndVibrationTitle: String {
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
#endif
// Mac OS Settings
#if os(iOS)
    extension SettingsView {
        private var macSettings: some View {
            VStack(alignment: .center, spacing: 0) {
                Text("Mac")
            }
            .frame(width: 400, height: 300)
            .navigationTitle(L10n.Settings.apperance)
            .preferredColorScheme(theme.appearance.colorScheme)
        }
    }
#endif

#if os(iOS)
    public extension SettingsView where HeadSection == EmptyView {
        init(@ViewBuilder appSection: () -> AppSection) {
            self.init(appSection: appSection, headSection: { EmptyView() })
        }
    }

#endif
#if os(iOS)
    extension UINavigationController: UIGestureRecognizerDelegate {
        override open func viewDidLoad() {
            super.viewDidLoad()
            interactivePopGestureRecognizer?.delegate = self
        }

        public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
            viewControllers.count > 1
        }
    }
#endif
