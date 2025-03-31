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
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

public struct FeedbackView: View {
    @Environment(Router<SettingsScreen>.self) var router
    public init() {}

    public var body: some View {
        Page("Feedback") {
            VStack(spacing: .large) {
                SectionView {
                    FeedbackViewRows()
                }
                .sectionContentCompactRowMargins()

                hero
                    .padding(.bottom, .medium)
            }
        }
        .backgroundSecondary()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    router.dismiss()
                } label: {
                    Image.Base.close.icon()
                }
            }
        }
    }

    private var hero: some View {
        AsyncIllustrationView("heros/dog.png")
            .frame(width: 156, height: 156)
    }
}

struct FeedbackViewRows: View {
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @Environment(Router<SettingsScreen>.self) var router

    var body: some View {
        LeadingVStack {
            if let reviewUrl = Info.url.appStoreReview, let id = Info.app.appStoreID, !id.isEmpty {
                Link(destination: reviewUrl) {
                    Row(L10n.Settings.feedbakAppStore) {
                        heartIcon.icon()
                    }
                }
                .buttonStyle(.row)
            }

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
                    router.present(.sendMail(to: mail, subject: subject, content: contentPreText))
                } leading: {
                    mailIcon.icon()
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
            #elseif os(macOS)

            if let mail = Info.links?.company.email,
               let appVersion = Info.app.verstion,
               let appName = Info.app.name,
               let appBuild = Info.app.build,
               let systemVersion = Info.app.system
            {
                let contentPreText = "\n\n\n\n\n\n————————————————\nApp: \(appName) \(appVersion) (\(appBuild))\nDevice: \(systemVersion)\nLocale: \(Info.app.language ?? "Not init")"
                let subject = "Feedback"

                let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let encodedBody = contentPreText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                if let mailtoURL = URL(string: "mailto:\(mail)?subject=\(encodedSubject)&body=\(encodedBody)") {
                    Row(L10n.Settings.feedbakAuthor) {
                        NSWorkspace.shared.open(mailtoURL)
                    } leading: {
                        mailIcon.icon()
                    }
                } else {
                    if let sendMailUrl = Info.url.developerSendMail {
                        Link(destination: sendMailUrl) {
                            Row(L10n.Settings.feedbakAuthor) {
                                mailIcon.icon()
                            }
                        }
                        .buttonStyle(.row)
                    }
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

    var heartIcon: Image {
        switch iconStyle {
        case .line:
            Image.Brands.appStore
        case .fill:
            Image.Brands.AppStore.fill
        case .twoTone:
            Image.Brands.AppStore.twoTone
        }
    }

    var mailIcon: Image {
        switch iconStyle {
        case .line:
            Image.Email.email
        case .fill:
            Image.Email.Email.fill
        case .twoTone:
            Image.Email.Email.twoTone
        }
    }

    var chatIcon: Image {
        switch iconStyle {
        case .line:
            Image.Brands.telegram
        case .fill:
            Image.Brands.Telegram.fill
        case .twoTone:
            Image.Brands.Telegram.twoTone
        }
    }
}
