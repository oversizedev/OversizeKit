//
// Copyright © 2022 Alexander Romanov
// SupportView.swift
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

public struct SupportView: View {
    @Environment(Router<SettingsScreen>.self) var router
    @Environment(\.iconStyle) var iconStyle: IconStyle
    public init() {}

    public var body: some View {
        Page(L10n.Settings.supportSection) {
            VStack(spacing: .large) {
                help

                hero
                    .padding(.bottom, .medium)
            }
        }
        .backgroundSecondary()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    router.dismissSheet()
                } label: {
                    Image.Base.close.icon()
                }
            }
        }
    }

    private var hero: some View {
        AsyncIllustrationView("heros/robot-assistant.png")
            .frame(width: 156, height: 156)
    }

    private var help: some View {
        SectionView {
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
                        let subject = "Support"

                        Row("Contact Us") {
                            router.present(.sendMail(to: mail, subject: subject, content: contentPreText))
                        } leading: {
                            mailIcon.icon()
                        }
                    } else {
                        // Send author
                        if let sendMailUrl = Info.url.developerSendMail {
                            Link(destination: sendMailUrl) {
                                Row("Contact Us") {
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
        .sectionContentCompactRowMargins()
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
