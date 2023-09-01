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
        @EnvironmentObject var hudState: HUDDeprecated

        let appSection: AppSection
        let headSection: HeadSection

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
                                apperanceSettingsIcon.icon()
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.сloudKit.valueOrFalse || FeatureFlags.app.healthKit.valueOrFalse {
                        NavigationLink(destination: iCloudSettingsView()
                        ) {
                            Row(L10n.Title.synchronization) {
                                cloudKitIcon.icon()
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
                                securityIcon.icon()
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.sounds.valueOrFalse || FeatureFlags.app.vibration.valueOrFalse {
                        NavigationLink(destination: SoundsAndVibrationsSettingsView()
                        ) {
                            Row(soundsAndVibrationTitle) {
                                FeatureFlags.app.sounds.valueOrFalse ? soundIcon.icon() : vibrationIcon.icon()
                            }
                            .rowArrow(isShowArrow)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.notifications.valueOrFalse {
                        NavigationLink(destination: NotificationsSettingsView()
                        ) {
                            Row(L10n.Settings.notifications) {
                                notificationsIcon.icon()
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
                return Image.Design.paintingPalette
            case .fill:
                return Image.Design.PaintingPalette.fill
            case .twoTone:
                return Image.Design.PaintingPalette.twoTone
            }
        }

        var cloudKitIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Weather.cloud2
            case .fill:
                return Image.Weather.Cloud.Square.fill
            case .twoTone:
                return Image.Weather.Cloud.Square.twoTone
            }
        }

        var securityIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.lock
            case .fill:
                return Image.Base.Lock.fill
            case .twoTone:
                return Image.Base.Lock.TwoTone.fill
            }
        }

        var soundIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.volumeUp
            case .fill:
                return Image.Base.VolumeUp.fill
            case .twoTone:
                return Image.Base.VolumeUp.TwoTone.fill
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

        var notificationsIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.notification
            case .fill:
                return Image.Base.Notification.fill
            case .twoTone:
                return Image.Base.Notification.TwoTone.fill
            }
        }

        // App Store Review
        private var help: some View {
            SectionView(L10n.Settings.supportSection) {
                VStack(alignment: .leading) {
                    Row("Get help") {
                        isShowSupport.toggle()
                    } leading: {
                        helpIcon.icon()
                    }
                    .rowArrow(isShowArrow)

                    .buttonStyle(.row)
                    .sheet(isPresented: $isShowSupport) {
                        SupportView()
                            .presentationDetents([.medium])
                            .presentationContentInteraction(.resizes)
                            .presentationCompactAdaptation(.sheet)
                            .scrollDisabled(true)
                    }

                    Row("Send feedback") {
                        isShowFeedback.toggle()
                    } leading: {
                        chatIcon.icon()
                    }
                    .rowArrow(isShowArrow)

                    .buttonStyle(.row)
                    .sheet(isPresented: $isShowFeedback) {
                        FeedbackView()
                            .presentationDetents([.height(560)])
                            .presentationContentInteraction(.resizes)
                            .presentationCompactAdaptation(.sheet)
                            .scrollDisabled(true)
                    }
                }
            }
        }

        var heartIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.heart
            case .fill:
                return Image.Base.Heart.fill
            case .twoTone:
                return Image.Base.Heart.TwoTone.fill
            }
        }

        var mailIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.message
            case .fill:
                return Image.Base.Message.fill
            case .twoTone:
                return Image.Base.Message.TwoTone.fill
            }
        }

        var chatIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.chat
            case .fill:
                return Image.Base.Chat.fill
            case .twoTone:
                return Image.Base.Chat.twoTone
            }
        }

        var infoIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.info
            case .fill:
                return Image.Base.Info.Circle.fill
            case .twoTone:
                return Image.Base.Info.Circle.twoTone
            }
        }

        var oversizeIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Brands.oversize
            case .fill:
                return Image.Brands.Oversize.fill
            case .twoTone:
                return Image.Brands.Oversize.TwoTone.fill
            }
        }

        var helpIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Alert.Help.circle
            case .fill:
                return Image.Alert.Help.Circle.fill
            case .twoTone:
                return Image.Alert.Help.Circle.twoTone
            }
        }

        private var about: some View {
            SectionView {
                VStack(spacing: .zero) {
                    NavigationLink(destination: AboutView()) {
                        Row(L10n.Settings.about) {
                            infoIcon.icon()
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
