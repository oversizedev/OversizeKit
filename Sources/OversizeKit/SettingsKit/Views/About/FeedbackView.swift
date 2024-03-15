//
// Copyright © 2022 Alexander Romanov
// FeedbackView.swift
//

#if canImport(MessageUI)
    import MessageUI
#endif
import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
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
            BarButton(.close)
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
                    Row(L10n.Settings.feedbakAppStore) {
                        heartIcon.icon()
                    }
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
                        } leading: {
                            mailIcon.icon()
                        }

                        .buttonStyle(.row)
                        .sheet(isPresented: $isShowMail) {
                            MailView(to: mail, subject: subject, content: contentPreText)
                        }
                    } else {
                        // Send author
                        if let sendMailUrl = Info.url.developerSendMail {
                            Link(destination: sendMailUrl) {
                                Row(L10n.Settings.feedbakAuthor) {
                                    mailIcon.icon()
                                }
                            }
                            .buttonStyle(.row)
                        }
                    }
                #endif

                // Telegramm chat
                if let telegramChatUrl = Info.url.appTelegramChat, let id = Info.app.telegramChatID, !id.isEmpty {
                    Link(destination: telegramChatUrl) {
                        Row(L10n.Settings.telegramChat) {
                            chatIcon.icon()
                        }
                    }
                    .buttonStyle(.row)
                }
            }
        }
    }

    var heartIcon: Image {
        switch iconStyle {
        case .line:
            return Image.Brands.appStore
        case .fill:
            return Image.Brands.AppStore.fill
        case .twoTone:
            return Image.Brands.AppStore.twoTone
        }
    }

    var mailIcon: Image {
        switch iconStyle {
        case .line:
            return Image.Email.email
        case .fill:
            return Image.Email.Email.fill
        case .twoTone:
            return Image.Email.Email.twoTone
        }
    }

    var chatIcon: Image {
        switch iconStyle {
        case .line:
            return Image.Brands.telegram
        case .fill:
            return Image.Brands.Telegram.fill
        case .twoTone:
            return Image.Brands.Telegram.twoTone
        }
    }
}
