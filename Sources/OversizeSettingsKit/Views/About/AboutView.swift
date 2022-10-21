//
// Copyright © 2022 Alexander Romanov
// AboutView.swift
//

import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeUI
import SwiftUI

// swiftlint:disable all
#if os(iOS)
    public struct AboutView: View {
        @State var isSharePresented = false
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.presentationMode) var presentationMode
        @State var offset = CGPoint(x: 0, y: 0)

        public init() {}

        public var body: some View {
            #if os(iOS)
                PageView(L10n.Settings.about) {
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

            //                if let authorAllApps = InfoStore.url.authorAllApps {
            //                    Link(destination: authorAllApps) {
            //                        Text(LocalizeLabel.about.otherApplications, bundle: .module)
            //                    }
            //
            //                }
        }

        private var list: some View {
            VStack(spacing: .zero) {
                header

                soclal
                    .padding(.bottom, .small)

                SectionView {
                    VStack(spacing: .zero) {
                        if let sendMailUrl = AppInfo.url.developerSendMail {
                            Link(destination: sendMailUrl) {
                                Row(L10n.About.suggestIdea)
                            }
                            .buttonStyle(.row)
                        }

                        #if os(iOS)
                            if let shareUrl = AppInfo.url.appInstallShare, let id = AppInfo.app.appStoreID, !id.isEmpty {
                                Row(L10n.Settings.shareApplication) {
                                    isSharePresented.toggle()
                                }
                                .sheet(isPresented: $isSharePresented, content: {
                                    ActivityViewController(activityItems: [shareUrl])
                                })
                            }
                        #endif
                    }
                }

                SectionView {
                    VStack(spacing: .zero)  {
                        HStack {
                            Text(L10n.About.otherApplications.uppercased())
                                .caption(true)
                                .foregroundColor(.onSurfaceMediumEmphasis)
                                .padding(.top, 12)
                                .paddingContent(.horizontal)
                                .padding(.bottom, 8)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Space.small) {
                                if let dressWeather = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1552617598") {
                                    Link(destination: dressWeather) {
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
                                    }
                                }

                                if let pinWalletLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1477792790") {
                                    Link(destination: pinWalletLink) {
                                        Resource.AppsIcons.pinWallet
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous))
                                    }
                                }

                                if let fmLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1498304700") {
                                    Link(destination: fmLink) {
                                        Resource.AppsIcons.fm
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16,
                                                                 style: .continuous)
                                                    .stroke(lineWidth: 1)
                                                    .opacity(0.15)
                                            )
                                    }
                                }

                                if let baskrt = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1490018969") {
                                    Link(destination: baskrt) {
                                        Resource.AppsIcons.basket
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous))
                                    }
                                }

                                if let jornalLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1508796556") {
                                    Link(destination: jornalLink) {
                                        Resource.AppsIcons.jornal
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous))
                                    }
                                }

                                if let randomLink = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1459928736") {
                                    Link(destination: randomLink) {
                                        Resource.AppsIcons.random
                                            .resizable()
                                            .frame(width: 74, height: 74)
                                            .mask(RoundedRectangle(cornerRadius: 16,
                                                                   style: .continuous))
                                    }
                                }

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

                            }.paddingContent(.horizontal)
                        }
                        .padding(.bottom, 16)
                    }
                }
                footer
            }
        }

        private var soclal: some View {
            HStack(spacing: .small) {
                if let facebook = AppInfo.url.companyFacebook {
                    Link(destination: facebook) {
                        Surface {
                            HStack {
                                Spacer()
                                Icon.Solid.SocialMediaandBrands.facebook
                                    .renderingMode(.template)
                                    .foregroundColor(Color.onSurfaceMediumEmphasis)
                                Spacer()
                            }
                        }
                    }
                }

                if let instagram = AppInfo.url.companyInstagram {
                    Link(destination: instagram) {
                        Surface {
                            HStack {
                                Spacer()
                                Icon.Solid.SocialMediaandBrands.instagram
                                    .renderingMode(.template)
                                    .foregroundColor(Color.onSurfaceMediumEmphasis)
                                Spacer()
                            }
                        }
                    }
                }
                
                if let twitter = AppInfo.url.companyTwitter {
                    Link(destination: twitter) {
                        Surface {
                            HStack {
                                Spacer()
                                Icon.Solid.SocialMediaandBrands.twitter
                                    .renderingMode(.template)
                                    .foregroundColor(Color.onSurfaceMediumEmphasis)
                                Spacer()
                            }
                        }
                    }
                }
                
                /*
                if let telegram = AppInfo.url.companyTelegram {
                    Link(destination: telegram) {
                        Surface {
                            HStack {
                                Spacer()
                                Icon(.send, color: .onSurfaceMediumEmphasis)
                                
                                Spacer()
                            }
                        }
                    }
                }
                 */
                
                if let dribbble = AppInfo.url.companyDribbble {
                    Link(destination: dribbble) {
                        Surface {
                            HStack {
                                Spacer()
                                Icon.Solid.SocialMediaandBrands.dribbble
                                    .renderingMode(.template)
                                    .foregroundColor(Color.onSurfaceMediumEmphasis)
                                Spacer()
                            }
                        }
                    }
                }
                
                
            }
            .buttonStyle(.scale)
            .controlPadding(.xSmall)
            .paddingContent(.horizontal)
        }

        private var header: some View {
            HStack {
                Spacer()

                VStack(alignment: .center) {
                    #if os(iOS)
                        if let appImage = AppInfo.app.iconName {
                            Image(uiImage: UIImage(named: appImage) ?? UIImage())
                                .resizable()
                                .frame(width: 128, height: 128)
                                .mask(RoundedRectangle(cornerRadius: 28,
                                                       style: .continuous))
                                .padding(.top, Space.xxLarge)
                        }

                    #endif
                    if let appVersion = AppInfo.app.verstion {
                        Text("Version \(appVersion)").multilineTextAlignment(.center)
                            .body(.semibold)
                            .foregroundColor(.onBackgroundMediumEmphasis)
                            .padding(.top, Space.small)
                            .padding(.bottom, Space.xLarge)
                    }
                }

                Spacer()
            }
        }

        private var footer: some View {
            HStack {
                Spacer()

                VStack(alignment: .center) {
                    if let authorLink = AppInfo.url.developerTelegram {
                        Link(destination: authorLink) {
                            if let developerName = AppInfo.developer.name {
                                Text(developerName)
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
            .padding(.vertical, Space.small)
        }
    }

    struct AboutView_Previews: PreviewProvider {
        static var previews: some View {
            AboutView()
        }
    }
#endif
