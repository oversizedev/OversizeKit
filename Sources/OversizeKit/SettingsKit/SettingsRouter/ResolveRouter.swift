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
            SyncSettingsView()
        case let .premiumFeature(feature: feature):
            StoreFeatureDetailView(selection: feature)
        case .about:
            AboutView()
        case .feedback:
            FeedbackView()
                .presentationDetents([.height(485)])
        case .ourResources:
            OurResourcesView()
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
            #if canImport(WebKit)
            WebView(url: url)
            #else
            EmptyView()
            #endif
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
        case .debugMenu:
            DebugMenuView()
        case .debugInfo:
            DebugInfoView()
        case let .premiumInstructions(specialOfferMode):
            StoreInstructionsView(specialOfferMode: specialOfferMode)
        case .appUpdates:
            AppUpdates.buildCached()
        case let .appUpdate(version):
            AppUpdate.build(input: .init(version: version))
        }
    }

    public var method: NavigationMethod {
        switch self {
        case .webView, .sendMail, .updatePINCode, .setPINCode, .support, .feedback, .premium, .offer, .premiumFeature, .debugMenu, .debugInfo:
            .managedSheet
        default:
            .push
        }
    }
}
