//
// Copyright © 2024 Alexander Romanov
// ResolveRouter.swift, created on 16.05.2024
//

import Foundation
import OversizeComponents
import OversizeLocalizable
import OversizeNetwork
import OversizeRouter
import SwiftUI

extension SettingsScreen: @preconcurrency RoutableView {
    @MainActor @ViewBuilder
    public func view() -> some View {
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
        case .ourResorses:
            OurResorsesView()
        case .support:
            SupportView()
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
}
