//
// Copyright © 2022 Alexander Romanov
// AboutView.swift
//

import MessageUI
import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStoreKit
import OversizeUI
import SwiftUI

// swiftlint:disable all
#if os(iOS)
    public struct AboutView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.screenSize) var screenSize
        @Environment(\.iconStyle) var iconStyle: IconStyle

        @State var offset: CGFloat = 0

        @State var isSharePresented = false
        @State private var isShowMail = false

        @State var isShowPrivacy = false
        @State var isShowTerms = false

        @State private var isPresentStoreProduct: Bool = false

        var isLargeScreen: Bool {
            screenSize.width < 500 ? false : true
        }

        var oppacity: CGFloat {
            if offset < 0 {
                return 1
            } else if offset > 500 {
                return 0
            } else {
                return Double(1 / (offset * 0.01))
            }
        }

        var blur: CGFloat {
            if offset < 0 {
                return 0
            } else {
                return Double(offset * 0.05)
            }
        }

        #if os(iOS)
            let scale = UIScreen.main.scale
        #else
            let scale: CGFloat = 2
        #endif

        public init() {}

        public var body: some View {
            #if os(iOS)
                PageView(L10n.Settings.about, onOffsetChanged: { offset = $0 }) {
                    list
                }
                .leadingBar {
                    if !isPortrait, verticalSizeClass == .regular {
                        EmptyView()
                    } else {
                        BarButton(type: .back)
                    }
                }
                .backgroundSecondary()

            #else
                list
                    .navigationTitle(L10n.Settings.about)
            #endif
        }

        private var list: some View {
            VStack(spacing: .zero) {
                image
                    .padding(.top, isLargeScreen ? -70 : 0)

                if isLargeScreen {
                    HStack(spacing: .xxSmall) {
                        Icon.Solid.SocialMediaandBrands.oversize
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.onSurfaceHighEmphasis)
                            .frame(width: 32, height: 32)

                        Resource.overszieTextLogo
                            .renderingMode(.template)
                            .foregroundColor(Color.onSurfaceHighEmphasis)
                    }
                    .padding(.top, -40)
                    .padding(.bottom, .xSmall)

                } else {
                    VStack(spacing: .xxSmall) {
                        Icon.Solid.SocialMediaandBrands.oversize
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.onSurfaceHighEmphasis)
                            .frame(width: 48, height: 48)

                        Resource.overszieTextLogo
                            .renderingMode(.template)
                            .foregroundColor(Color.onSurfaceHighEmphasis)
                    }
                    .padding(.top, 42)
                    .padding(.bottom, .medium)
                }

                Text("The Oversize project is made with love and attention to the design of the forces of only one person")
                    .title3(.semibold)
                    .foregroundColor(.onBackgroundHighEmphasis)
                    .padding(.horizontal, isLargeScreen ? 72 : 52)
                    .padding(.bottom, .large)

                    .multilineTextAlignment(.center)

                soclal
                    .padding(.bottom, .small)

                SectionView {
                    VStack(spacing: .zero) {
                        if let reviewUrl = AppInfo.url.appStoreReview, let id = AppInfo.app.appStoreID, !id.isEmpty, let appName = AppInfo.app.name {
                            Link(destination: reviewUrl) {
                                Row("Rate \(appName) on App Store")
                                    .rowLeading(.image(rateSettingsIcon))
                            }
                            .buttonStyle(.row)
                        }

                        if MFMailComposeViewController.canSendMail(),
                           let mail = AppInfo.developer.email,
                           let appVersion = AppInfo.app.verstion,
                           let appName = AppInfo.app.name,
                           let device = AppInfo.app.device,
                           let appBuild = AppInfo.app.build,
                           let systemVersion = AppInfo.app.system
                        {
                            let contentPreText = "\n\n\n\n\n\n————————————————\nApp: \(appName) \(appVersion) (\(appBuild))\nDevice: \(device), \(systemVersion)\nLocale: \(AppInfo.app.language ?? "Not init")"
                            let subject = "Feedback"

                            Row(L10n.About.suggestIdea) {
                                isShowMail.toggle()
                            }
                            .rowLeading(.image(ideaSettingsIcon))

                            .buttonStyle(.row)
                            .sheet(isPresented: $isShowMail) {
                                MailView(to: mail, subject: subject, content: contentPreText)
                            }
                        }

                        #if os(iOS)
                            if let shareUrl = AppInfo.url.appInstallShare, let id = AppInfo.app.appStoreID, !id.isEmpty {
                                Row(L10n.Settings.shareApplication) {
                                    isSharePresented.toggle()
                                }
                                .rowLeading(.image(shareSettingsIcon))
                                .sheet(isPresented: $isSharePresented) {
                                    ActivityViewController(activityItems: [shareUrl])
                                        .presentationDetents([.medium, .large])
                                }
                            }
                        #endif
                    }
                }

                SectionView {
                    VStack(spacing: .zero) {
                        HStack {
                            Text(L10n.About.otherApplications.uppercased())
                                .caption(true)
                                .foregroundColor(.onSurfaceMediumEmphasis)
                                .padding(.top, 12)
                                .padding(.leading, 26)
                                .padding(.bottom, 18)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Space.small) {
                                ForEach(AppInfo.all?.apps ?? []) { app in
                                    VStack {
                                        Resource.AppsIcons.dressWeather
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16,
                                                                 style: .continuous)
                                                    .stroke(lineWidth: 1)
                                                    .opacity(0.15)
                                            )
                                            .appStoreOverlay(isPresent: $isPresentStoreProduct, appId: app.id ?? "")
                                            .onTapGesture {
                                                isPresentStoreProduct = true
                                            }

                                        Text(app.name ?? "")
                                    }
                                }

//                                if let pinWalletLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1477792790") {
//                                    Link(destination: pinWalletLink) {
//                                        Resource.AppsIcons.pinWallet
//                                            .resizable()
//                                            .frame(width: 74, height: 74)
//                                            .mask(RoundedRectangle(cornerRadius: 16,
//                                                                   style: .continuous))
//                                    }
//                                }
//
//                                if let fmLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1498304700") {
//                                    Link(destination: fmLink) {
//                                        Resource.AppsIcons.fm
//                                            .resizable()
//                                            .frame(width: 74, height: 74)
//                                            .mask(RoundedRectangle(cornerRadius: 16,
//                                                                   style: .continuous)
//                                            )
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 16,
//                                                                 style: .continuous)
//                                                    .stroke(lineWidth: 1)
//                                                    .opacity(0.15)
//                                            )
//                                    }
//                                }
//
//                                if let baskrt = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1490018969") {
//                                    Link(destination: baskrt) {
//                                        Resource.AppsIcons.basket
//                                            .resizable()
//                                            .frame(width: 74, height: 74)
//                                            .mask(RoundedRectangle(cornerRadius: 16,
//                                                                   style: .continuous))
//                                    }
//                                }
//
//                                if let jornalLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1508796556") {
//                                    Link(destination: jornalLink) {
//                                        Resource.AppsIcons.jornal
//                                            .resizable()
//                                            .frame(width: 74, height: 74)
//                                            .mask(RoundedRectangle(cornerRadius: 16,
//                                                                   style: .continuous))
//                                    }
//                                }
//
//                                if let randomLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1459928736") {
//                                    Link(destination: randomLink) {
//                                        Resource.AppsIcons.random
//                                            .resizable()
//                                            .frame(width: 74, height: 74)
//                                            .mask(RoundedRectangle(cornerRadius: 16,
//                                                                   style: .continuous))
//                                    }
//                                }

                                if let authorAllApps = AppInfo.url.developerAllApps {
                                    Link(destination: authorAllApps) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .foregroundColor(.surfaceSecondary)
                                                .frame(width: 74, height: 74)

                                            Icon(.externalLink)
                                        }
                                    }
                                }

                            }.padding(.horizontal, .medium)
                        }
                        .padding(.bottom, 16)
                    }
                }

                SectionView {
                    VStack(spacing: .zero) {
                        NavigationLink(destination: OurResorsesView()) {
                            Row("Our open resources",
                                trallingType: .arrowIcon)
                        }
                        .buttonStyle(.row)

                        if let privacyUrl = AppInfo.url.appPrivacyPolicyUrl {
                            Row(L10n.Store.privacyPolicy) {
                                isShowPrivacy.toggle()
                            }
                            .sheet(isPresented: $isShowPrivacy) {
                                WebView(url: privacyUrl)
                            }
                        }

                        if let termsOfUde = AppInfo.url.appTermsOfUseUrl {
                            Row(L10n.Store.termsOfUse) {
                                isShowTerms.toggle()
                            }
                            .sheet(isPresented: $isShowTerms) {
                                WebView(url: termsOfUde)
                            }
                        }
                    }
                }

                footer
            }
        }

        private var soclal: some View {
            HStack(spacing: .small) {
                if let facebook = AppInfo.links?.company.facebookUrl {
                    Link(destination: facebook) {
                        // Surface {
                        HStack {
                            Spacer()
                            Icon.Solid.SocialMediaandBrands.facebook
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let instagram = AppInfo.url.companyInstagram {
                    Link(destination: instagram) {
                        // Surface {
                        HStack {
                            Spacer()
                            Icon.Solid.SocialMediaandBrands.instagram
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let twitter = AppInfo.url.companyTwitter {
                    Link(destination: twitter) {
                        // Surface {
                        HStack {
                            Spacer()
                            Icon.Solid.SocialMediaandBrands.twitter
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let telegramUrl = AppInfo.url.companyTelegram {
                    Link(destination: telegramUrl) {
                        // Surface {
                        HStack {
                            Spacer()
                            Icon.Solid.SocialMediaandBrands.telegram
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let dribbble = AppInfo.url.companyDribbble {
                    Link(destination: dribbble) {
                        //  Surface {
                        HStack {
                            Spacer()
                            Icon.Solid.SocialMediaandBrands.dribbble
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        //  }
                    }
                }
            }
            .buttonStyle(.scale)
            .frame(maxWidth: 300)
            .controlPadding(.xSmall)
            .paddingContent(.horizontal)
        }

        private var image: some View {
            HStack {
                VStack(alignment: .center) {
                    ZStack(alignment: .top) {
                        AsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer3.png"), scale: scale) {
                            $0
                                .resizable()
                                .scaledToFit()
                                .blur(radius: blur)
                        } placeholder: {
                            Rectangle()
                                .fillSurfaceTertiary()
                                .rotationEffect(.degrees(45))
                                .opacity(0)
                                .frame(height: screenSize.width / 1.16)
                        }
                        .offset(y: -offset * 0.1)

                        AsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer2.png"), scale: scale) {
                            $0
                                .resizable()
                                .scaledToFit()
                                .blur(radius: blur)
                        } placeholder: {
                            Rectangle()
                                .fillSurfaceTertiary()
                                .rotationEffect(.degrees(45))
                                .padding(200)
                                .frame(height: screenSize.width / 1.16)
                                .overlay {
                                    ProgressView()
                                }
                        }

                        AsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer1.png"), scale: scale) {
                            $0
                                .resizable()
                                .scaledToFit()
                                .blur(radius: blur)
                        } placeholder: {
                            Rectangle()
                                .fillSurfaceTertiary()
                                .rotationEffect(.degrees(45))
                                .opacity(0)
                                .frame(height: screenSize.width / 1.16)
                        }
                        .offset(y: -(offset * -0.04))
                    }
                    .scaleEffect(screenSize.width < 500 ? 1.4 : 0.9)
                    .opacity(screenSize.width < 500 ? oppacity : 1)
                }
            }
        }

        private var footer: some View {
            HStack {
                Spacer()

                VStack(alignment: .center) {
                    if let authorLink = AppInfo.links?.company.url {
                        Link(destination: authorLink) {
                            if let developerName = AppInfo.developer.name,
                               let appVersion = AppInfo.app.verstion,
                               let appName = AppInfo.app.name,
                               let appBuild = AppInfo.app.build
                            {
                                Text("© 2022 \(developerName). \(appName) \(appVersion) (\(appBuild))")
                                    .footnote()
                                    .foregroundColor(.onBackgroundDisabled)
                            } else {
                                Text("Developer")
                                    .footnote()
                                    .foregroundColor(.onBackgroundDisabled)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, Space.small)
            .padding(.bottom, 40)
        }

        var rateSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.heart
            case .solid:
                return Icon.Solid.UserInterface.heart
            case .duotone:
                return Icon.Duotone.UserInterface.heart
            }
        }

        var ideaSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.DevicesandElectronics.lightBulb
            case .solid:
                return Icon.Solid.DevicesandElectronics.lightBulb
            case .duotone:
                return Icon.Duotone.DevicesandElectronics.lightBulb
            }
        }

        var shareSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.UserInterface.export
            case .solid:
                return Icon.Solid.UserInterface.export
            case .duotone:
                return Icon.Duotone.UserInterface.export
            }
        }
    }

    struct AboutView_Previews: PreviewProvider {
        static var previews: some View {
            AboutView()
        }
    }
#endif

#if os(iOS)
    import UIKit
    extension UIScrollView {
        override open var clipsToBounds: Bool {
            get { false }
            set {}
        }
    }
#endif
