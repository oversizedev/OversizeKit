//
// Copyright © 2024 Alexander Romanov
// ResolveRouter.swift, created on 16.05.2024
//

import NavigatorUI
import OversizeComponents
import OversizeNetwork
import SwiftUI

extension SettingsDestinations: NavigationDestination {
    public var body: some View {
        switch self {
        case .premium:
            StoreView()
        case .soundAndVibration:
            SoundsAndVibrationsSettingsView()
        case .appearance:
            AppearanceSettingView()
        case .sync:
            iCloudSettingsView()
        case let .premiumFeature(feature: feature):
            StoreFeatureDetailView(selection: feature)
        case .about:
            AboutView()
        case .feedback:
            FeedbackView()
                .presentationDetents([.height(485)])
        case .ourResorses:
            OurResorsesView()
        case .support:
            SupportView()
                .presentationDetents([.height(460)])
        case .border:
            BorderSettingView()
        case .font:
            FontSettingView()
        case .radius:
            RadiusSettingView()
        case .notifications:
            NotificationsSettingsView()
        case .setPINCode:
            SetPINCodeView(action: .set)
        case .updatePINCode:
            SetPINCodeView(action: .update)
        case .security:
            SecuritySettingsView()
        case let .offer(event: event):
            StoreSpecialOfferView(event: event)
        case let .webView(url: url):
            WebView(url: url)
        case let .sendMail(to: to, subject: subject, content: content):
            #if os(iOS)
            MailView(
                to: to,
                subject: subject,
                content: content
            )
            #else
            EmptyView()
            #endif
        }
    }

    public var method: NavigationMethod {
        switch self {
        case .webView, .sendMail, .updatePINCode, .setPINCode, .support, .feedback, .premium, .offer, .premiumFeature:
            .managedSheet
        default:
            .push
        }
    }
}
