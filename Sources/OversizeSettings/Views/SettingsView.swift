//
// Copyright © 2022 Alexander Romanov
// SettingsView.swift
//

import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStore
import OversizeStoreService
import OversizeUI
import SwiftUI

// swiftlint:disable line_length
#if os(iOS)
    public struct SettingsView<AppSection: View, HeadSection: View>: View {
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.theme) var theme: ThemeSettings
        @StateObject var settingsService = SettingsService()
        @EnvironmentObject var hudState: HUD

        let appSection: AppSection
        let headSection: HeadSection

        @State private var offset = CGPoint(x: 0, y: 0)
        @State private var isPortrait = false

        var rowType: RowTrailingType? {
            #if os(iOS)
                if !isPortrait, verticalSizeClass == .regular {
                    return nil
                } else {
                    return .arrowIcon
                }
            #else
                return .arrowIcon

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
                    guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                    self.isPortrait = scene.interfaceOrientation.isPortrait
                }
                .portraitMode(isPortrait)

            #else
                macSettings

            #endif
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
                        SectionView(verticalPadding: .zero) {
                            PrmiumBannerRow()
                        }
                    }
                }
                app
                help
                about
            }
        }
    }
#endif

#if os(iOS)
    // Sections
    extension SettingsView {
        private var head: some View {
            SectionView(verticalPadding: .zero) {
                headSection
            }
        }

        private var app: some View {
            SectionView(L10n.Settings.appSection) {
                VStack(spacing: .zero) {
                    if FeatureFlags.app.apperance.valueOrFalse {
                        NavigationLink(destination: AppearanceSettingView()
                        ) {
                            Row(L10n.Settings.apperance)
                                .rowLeading(.image(Icon.Plumpy.paintPalette))
                                .rowTrailing(rowType)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.сloudKit.valueOrFalse {
                        NavigationLink(destination: iCloudSettingsView()
                        ) {
                            Row(L10n.Title.synchronization, leadingType: .image(Icon.Plumpy.cloud), trallingType: rowType)
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
                            Row(L10n.Security.title, leadingType: .image(Icon.Plumpy.lock), trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.sounds.valueOrFalse || FeatureFlags.app.vibration.valueOrFalse {
                        NavigationLink(destination: SoundsAndVibrationsSettingsView()
                        ) {
                            Row(soundsAndVibrationTitle,
                                leadingType: .image(FeatureFlags.app.sounds.valueOrFalse ? Icon.Plumpy.music : Icon.Plumpy.radioWaves),
                                trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }

                    if FeatureFlags.app.notifications.valueOrFalse {
                        NavigationLink(destination: NotificationsSettingsView()
                        ) {
                            Row(L10n.Settings.notifications, leadingType: .image(Icon.Plumpy.notification), trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }

                    appSection
                }
            }
        }

        // App Store Review
        private var help: some View {
            SectionView(L10n.Settings.supportSection) {
                VStack(alignment: .leading) {
                    if let reviewUrl = AppInfo.url.appStoreReview, let id = AppInfo.app.appStoreID, !id.isEmpty {
                        Link(destination: reviewUrl) {
                            Row(L10n.Settings.feedbakAppStore, leadingType: .image(Icon.Plumpy.heart), trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }

                    // Send author
                    if let sendMailUrl = AppInfo.url.developerSendMail { // , let mail = InfoStore.app.mail, !mail.isEmpty {
                        Link(destination: sendMailUrl) {
                            Row(L10n.Settings.feedbakAuthor, leadingType: .image(Icon.Plumpy.message), trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }

                    // Telegramm chat
                    if let telegramChatUrl = AppInfo.url.appTelegramChat, let id = AppInfo.app.telegramChatID, !id.isEmpty {
                        Link(destination: telegramChatUrl) {
                            Row(L10n.Settings.telegramChat, leadingType: .image(Icon.Plumpy.send), trallingType: rowType)
                        }
                        .buttonStyle(.row)
                    }
                }
            }
        }

        private var about: some View {
            SectionView {
                NavigationLink(destination: AboutView()) {
                    Row(L10n.Settings.about,
                        leadingType: .image(Icon.Plumpy.infoCircle),
                        trallingType: rowType)
                }
                .buttonStyle(.row)
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

    // public extension SettingsView where AppSection == EmptyView {
//    init(@ViewBuilder headSection: () -> HeadSection) {
//        self.init(appSection: { EmptyView() }, headSection: headSection)
//    }
    // }
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

// public struct SettingsView<AppSection: View, TopSection: View>: View {
//
//    let appSection: AppSection
//    let topSection: TopSection
//
//    public init(@ViewBuilder appSection: @escaping () -> AppSection,
//                @ViewBuilder topSection: @escaping () -> TopSection) {
//        self.appSection = appSection()
//        self.topSection = topSection()
//    }
//
//    public var body: some View {
//
//        NavigationView {
//
//            List {
//
//                topSection
//
//                Section(header: Text(LocalizeLabel.settings.appSection)) {
//                    appSection
//                }
//
//                Section(header: Text(LocalizeLabel.settings.supportSection)) {
//
//                    if let reviewUrl = InfoStore.url.appStoreReview {
//
//
//
//                        Link("Оценить в AppStore", destination: reviewUrl)
//
//                    }
//                }
//
//                Section() {
//                NavigationLink(LocalizeLabel.settings.about, destination: AboutView())
//
//                }
//
//
//
//
//            }
//            .navigationTitle(LocalizeLabel.settings.title)
//            .listStyle(InsetGroupedListStyle())
//
//
//        }
//
//    }
// }
//
// public extension SettingsView where TopSection == EmptyView {
//    init(@ViewBuilder appSection: @escaping () -> AppSection) {
//        self.init(appSection: appSection, topSection: { EmptyView() })
//    }
// }

// extension SettingsView where TopSection == EmptyView {
//    init(@ViewBuilder appSection: () -> AppSection) {
//        self.init(appSection: appSection, topSection: { EmptyView() })
//    }
// }

// struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView {
//
//        }
//    }
// }
