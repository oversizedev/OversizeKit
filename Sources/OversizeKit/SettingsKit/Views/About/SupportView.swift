//
// Copyright © 2022 Alexander Romanov
// SupportView.swift
//

#if canImport(MessageUI)
import MessageUI
#endif
import NavigatorUI
import OversizeComponents
import OversizeLocalizable
import OversizeNavigation
import OversizeResources
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

public struct SupportView: View {
    @Environment(\.navigator) var navigator
    @Environment(\.iconStyle) var iconStyle: IconStyle
    public init() {}

    public var body: some View {
        NavigationLayoutView(L10n.Settings.supportSection) {
            VStack(spacing: .large) {
                help

                hero
                    .padding(.bottom, .medium)
            }
        } background: {
            Color.backgroundSecondary
        }
        .toolbarTitleDisplayMode(.inline)
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
                   let mail = Info.Developer.email,
                   let appVersion = Info.App.version,
                   let appName = Info.App.name,
                   let device = Info.App.device,
                   let appBuild = Info.App.build,
                   let systemVersion = Info.App.osVersion
                {
                    let contentPreText = "\n\n\n\n\n\n————————————————\nApp: \(appName) \(appVersion) (\(appBuild))\nDevice: \(device), \(systemVersion)\nLocale: \(Info.App.localeIdentifier ?? "Not init")"
                    let subject = "Support"

                    Row("Contact Us") {
                        navigator.navigate(
                            to: SettingsDestinations.sendMail(
                                to: mail,
                                subject: subject,
                                content: contentPreText
                            )
                        )

                    } leading: {
                        mailIcon.icon()
                    }
                } else {
                    // Send author
                    if let sendMailUrl = Info.Developer.emailUrl {
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
                if let telegramChatUrl = Info.App.telegramChatUrl, let id = Info.App.telegramChatId, !id.isEmpty {
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
