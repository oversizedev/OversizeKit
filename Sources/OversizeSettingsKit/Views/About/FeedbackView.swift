//
// Copyright © 2022 Alexander Romanov
// FeedbackView.swift
//

#if canImport(MessageUI)
    import MessageUI
#endif
import OversizeCDN
import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeStoreKit
import OversizeUI
import SwiftUI

public struct FeedbackView: View {
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @State private var isShowMail = false
    public init() {}

    public var body: some View {
        PageView("Feedback") {
            VStack(spacing: .large) {
                help

                hero
                    .padding(.bottom, .medium)
            }
        }
        .trailingBar {
            BarButton(type: .close)
        }
        .backgroundSecondary()
    }

    private var hero: some View {
        AsyncIllustrationView("heros/dog.png")
            .frame(width: 156, height: 156)
    }

    private var help: some View {
        SectionView {
            if let reviewUrl = Info.url.appStoreReview, let id = Info.app.appStoreID, !id.isEmpty {
                Link(destination: reviewUrl) {
                    Row(L10n.Settings.feedbakAppStore, leadingType: .image(heartIcon))
                }
                .buttonStyle(.row)
            }

            VStack(alignment: .leading) {
                #if os(iOS)
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

                        Row(L10n.Settings.feedbakAuthor) {
                            isShowMail.toggle()
                        }
                        .rowLeading(.image(mailIcon))

                        .buttonStyle(.row)
                        .sheet(isPresented: $isShowMail) {
                            MailView(to: mail, subject: subject, content: contentPreText)
                        }
                    } else {
                        // Send author
                        if let sendMailUrl = Info.url.developerSendMail {
                            Link(destination: sendMailUrl) {
                                Row(L10n.Settings.feedbakAuthor, leadingType: .image(mailIcon))
                            }
                            .buttonStyle(.row)
                        }
                    }
                #endif

                // Telegramm chat
                if let telegramChatUrl = Info.url.appTelegramChat, let id = Info.app.telegramChatID, !id.isEmpty {
                    Link(destination: telegramChatUrl) {
                        Row(L10n.Settings.telegramChat, leadingType: .image(chatIcon))
                    }
                    .buttonStyle(.row)
                }
            }
        }
    }

    var heartIcon: Image {
        switch iconStyle {
        case .line:
            return Icon.Line.SocialMediaandBrands.apple
        case .solid:
            return Icon.Solid.SocialMediaandBrands.apple
        case .duotone:
            return Icon.Duotone.SocialMediaandBrands.apple
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
            return Icon.Line.SocialMediaandBrands.telegram
        case .solid:
            return Icon.Solid.SocialMediaandBrands.telegram
        case .duotone:
            return Icon.Duotone.SocialMediaandBrands.telegram
        }
    }

//    var chatIcon: Image {
//        switch iconStyle {
//        case .line:
//            return Icon.Line.Communication.chatDots
//        case .solid:
//            return Icon.Solid.Communication.chatDots
//        case .duotone:
//            return Icon.Duotone.Communication.chatDots
//        }
//    }
}
