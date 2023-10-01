//
// Copyright © 2022 Alexander Romanov
// AboutView.swift
//

import CachedAsyncImage
import OversizeComponents
import OversizeCore
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeUI
import SwiftUI

// swiftlint:disable all
#if os(iOS)
    import MessageUI
    public struct AboutView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.screenSize) var screenSize
        @Environment(\.iconStyle) var iconStyle: IconStyle
        
        @StateObject var viewModel: AboutViewModel

        public init() {
            _viewModel = StateObject(wrappedValue: AboutViewModel())
        }

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

        public var body: some View {
            #if os(iOS)
                PageView(L10n.Settings.about, onOffsetChanged: { offset = $0 }) {
                    list
                        .surfaceContentRowMargins()
                        .task {
                            await viewModel.fetchApps()
                        }
                }
                .leadingBar {
                    /*
                     if !isPortrait, verticalSizeClass == .regular {
                         EmptyView()
                     } else {
                         BarButton(.back)
                     }
                      */
                    BarButton(.back)
                }
                .backgroundSecondary()

            #else
                list
                    .navigationTitle(L10n.Settings.about)
            #endif
        }

        private func appLinks() -> some View {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Space.small) {
                    switch viewModel.state {
                    case .initial, .loading:
                        ForEach(0...6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: .large, style: .continuous)
                                .fillSurfaceSecondary()
                                .frame(width: 74, height: 74)
                        }
                    case .result(let apps, _):
                        ForEach(apps, id: \.appStoreId) { app in
                            Button {
                                isPresentStoreProduct = true
                            } label: {
                                VStack(spacing: .xSmall) {
                                    CachedAsyncImage(url: URL(string: "https://cdn.oversize.design/assets/apps/" + app.address + "/icon.png"), urlCache: .imageCache, content: {
                                        $0
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: .large,
                                                                   style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16,
                                                                 style: .continuous)
                                                .stroke(lineWidth: 1)
                                                .opacity(0.15)
                                            )
                                        
                                    }, placeholder: {
                                        RoundedRectangle(cornerRadius: .large, style: .continuous)
                                            .fillSurfaceSecondary()
                                            .frame(width: 74, height: 74)
                                    })
                                    
                                    Text(app.name)
                                        .caption(.medium)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.onSurfaceMediumEmphasis)
                                        .frame(width: 74)
                                }
                            }
                            .buttonStyle(.scale)
                            .appStoreOverlay(isPresent: $isPresentStoreProduct, appId: app.appStoreId)
                        }
                    case .error:
                        EmptyView()
                    }
                    
                    
                    if let authorAllApps = Info.url.developerAllApps {
                        VStack(spacing: .xSmall) {
                            Link(destination: authorAllApps) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .foregroundColor(.surfaceSecondary)
                                        .frame(width: 74, height: 74)
                                    
                                    IconDeprecated(.externalLink)
                                }
                            }
                            
                            Text("All apps")
                                .caption(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.onSurfaceMediumEmphasis)
                                .frame(width: 74)
                        }
                    }
                    
                }.padding(.horizontal, .medium)
            }
            .padding(.bottom, 16)
        }
        
        var list: some View {
            VStack(spacing: .zero) {
                image
                    .padding(.top, isLargeScreen ? -70 : 0)

                if isLargeScreen {
                    HStack(spacing: .xxSmall) {
                        Image.Brands.Oversize.fill
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
                        Image.Brands.Oversize.fill
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
                        if let reviewUrl = Info.url.appStoreReview, let id = Info.app.appStoreID, !id.isEmpty, let appName = Info.app.name {
                            Link(destination: reviewUrl) {
                                Row("Rate \(appName) on App Store") {
                                    rateSettingsIcon
                                }
                            }
                            .buttonStyle(.row)
                        }

                        if MFMailComposeViewController.canSendMail(),
                           let mail = Info.links?.company.email,
                           let appVersion = Info.app.verstion,
                           let appName = Info.app.name,
                           let device = Info.app.device,
                           let appBuild = Info.app.build,
                           let systemVersion = Info.app.system
                        {
                            let contentPreText = "\n\n\n\n\n\n————————————————\nApp: \(appName) \(appVersion) (\(appBuild))\nDevice: \(device), \(systemVersion)\nLocale: \(Info.app.language ?? "Not init")"
                            let subject = "Feedback"

                            Row(L10n.About.suggestIdea) {
                                isShowMail.toggle()
                            } leading: {
                                ideaSettingsIcon
                            }

                            .buttonStyle(.row)
                            .sheet(isPresented: $isShowMail) {
                                MailView(to: mail, subject: subject, content: contentPreText)
                            }
                        }

                        #if os(iOS)
                            if let shareUrl = Info.url.appInstallShare, let id = Info.app.appStoreID, !id.isEmpty {
                                Row(L10n.Settings.shareApplication) {
                                    isSharePresented.toggle()
                                } leading: {
                                    shareSettingsIcon
                                }
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

                        appLinks()
                    }
                }

                SectionView {
                    VStack(spacing: .zero) {
                        NavigationLink(destination: OurResorsesView()) {
                            Row("Our open resources")
                                .rowArrow()
                        }
                        .buttonStyle(.row)

                        if let privacyUrl = Info.url.appPrivacyPolicyUrl {
                            Row(L10n.Store.privacyPolicy) {
                                isShowPrivacy.toggle()
                            }
                            .sheet(isPresented: $isShowPrivacy) {
                                WebView(url: privacyUrl)
                            }
                        }

                        if let termsOfUde = Info.url.appTermsOfUseUrl {
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
//                switch viewModel.state {
//                case .initial, .loading:
//                    ForEach(0...6, id: \.self) { _ in
//                        Circle()
//                            .fillSurfaceSecondary()
//                            .frame(width: 24, height: 24)
//                    }
//                case .result(_, let info):
//                    ForEach(info.company.socialNetworks, id: \.title) { link in
//                        if let linkUrl = URL(string: link.url), let iconUrl = URL(string: link.iconUrl) {
//                            Link(destination: linkUrl) {
//                                HStack {
//                                    Spacer()
//                                    
//                                    CachedAsyncImage(url: iconUrl, urlCache: .imageCache, scale: scale) {
//                                        $0
//                                            .resizable()
//                                            .scaledToFit()
//                                            .blur(radius: blur)
//                                    } placeholder: {
//                                        Circle()
//                                            .fillSurfaceSecondary()
//                                            .frame(width: 24, height: 24)
//                                    }
//                                    .offset(y: -(offset * -0.04))
//                                    
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//                case .error:
//                    EmptyView()
//                }
                
                
                
                if let facebook = Info.url.companyFacebook {
                    Link(destination: facebook) {
                        // Surface {
                        HStack {
                            Spacer()
                            Image.Brands.Facebook.Circle.fill
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let instagram = Info.url.companyInstagram {
                    Link(destination: instagram) {
                        // Surface {
                        HStack {
                            Spacer()
                            Image.Brands.Instagram.fill
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let twitter = Info.url.companyTwitter {
                    Link(destination: twitter) {
                        // Surface {
                        HStack {
                            Spacer()
                            Image.Brands.xCom
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let telegramUrl = Info.url.companyTelegram {
                    Link(destination: telegramUrl) {
                        // Surface {
                        HStack {
                            Spacer()
                            Image.Brands.Telegram.fill
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceMediumEmphasis)
                            Spacer()
                        }
                        // }
                    }
                }

                if let dribbble = Info.url.companyDribbble {
                    Link(destination: dribbble) {
                        //  Surface {
                        HStack {
                            Spacer()
                            Image.Brands.Dribbble.fill
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
            .controlMargin(.xSmall)
            .paddingContent(.horizontal)
        }

        private var image: some View {
            HStack {
                VStack(alignment: .center) {
                    ZStack(alignment: .top) {
                        CachedAsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer3.png"), urlCache: .imageCache, scale: scale) {
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

                        CachedAsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer2.png"), urlCache: .imageCache, scale: scale) {
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

                        CachedAsyncImage(url: URL(string: "https://cdn.oversize.design/assets/illustrations/scenes/about-layer1.png"), urlCache: .imageCache, scale: scale) {
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
                    if let authorLink = Info.links?.company.url {
                        Link(destination: authorLink) {
                            if let developerName = Info.developer.name,
                               let appVersion = Info.app.verstion,
                               let appName = Info.app.name,
                               let appBuild = Info.app.build
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
                return Image.Base.heart
            case .fill:
                return Image.Base.Heart.fill
            case .twoTone:
                return Image.Base.Heart.TwoTone.fill
            }
        }

        var ideaSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Electricity.lamp
            case .fill:
                return Image.Electricity.Lamp.fill
            case .twoTone:
                return Image.Electricity.Lamp.TwoTone.fill
            }
        }

        var shareSettingsIcon: Image {
            switch iconStyle {
            case .line:
                return Image.Base.send
            case .fill:
                return Image.Base.Send.fill
            case .twoTone:
                return Image.Base.Send.TwoTone.fill
            }
        }
    }

    struct AboutView_Previews: PreviewProvider {
        static var previews: some View {
            AboutView()
        }
    }
#endif
