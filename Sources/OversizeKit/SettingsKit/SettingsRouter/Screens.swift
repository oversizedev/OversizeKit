//
// Copyright © 2024 Alexander Romanov
// SettingsScreen.swift, created on 15.04.2024
//

import OversizeComponents
import OversizeModels
import OversizeNetwork
import OversizeRouter
import SwiftUI

public enum SettingsScreen: Routable {
    case premium
    case premiumFeature(feature: Components.Schemas.Feature)
    case soundAndVibration
    case appearance
    case sync
    case about
    case feedback
    case ourResorses
    case support
    case border
    case font
    case radius
    case notifications
    case setPINCode
    case updatePINCode
    case security
    case offer(event: Components.Schemas.InAppPurchaseOffer)
    case webView(url: URL)
    case sendMail(to: String, subject: String, content: String)
}

public extension SettingsScreen {
    var id: String {
        switch self {
        case .premium:
            "premium"
        case .premiumFeature:
            "premiumFeature"
        case .soundAndVibration:
            "soundAndVibration"
        case .appearance:
            "appearance"
        case .sync:
            "sync"
        case .about:
            "about"
        case .feedback:
            "feedback"
        case .webView:
            "webView"
        case .ourResorses:
            "ourResorses"
        case .support:
            "support"
        case .border:
            "border"
        case .font:
            "font"
        case .radius:
            "radius"
        case .setPINCode:
            "setPINCode"
        case .updatePINCode:
            "updatePINCode"
        case .security:
            "security"
        case .offer:
            "offer"
        case .sendMail:
            "sendMail"
        case .notifications:
            "notifications"
        }
    }
}

// public struct SettingsNavigateAction {
//    public typealias Action = (SettingsNavigationType) -> Void
//    public let action: Action
//    public func callAsFunction(_ navigationType: SettingsNavigationType) {
//        action(navigationType)
//    }
// }

// public enum SettingsNavigationType {
//    case move(SettingsScreen)
//    case backToRoot
//    case back(Int = 1)
//    case present(_ sheet: SettingsScreen, detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false)
//    case dismiss
//    case dismissSheet
//    case dismissFullScreenCover
//    case dismissDisabled(_ isDismissDisabled: Bool = true)
//    case presentHUD(_ text: String, type: HUDMessageType)
// }

//
// public struct SettingsNavigateEnvironmentKey: EnvironmentKey {
//    public static var defaultValue: SettingsNavigateAction = .init(action: { _ in })
// }
//
// public extension EnvironmentValues {
//    var settingsNavigate: SettingsNavigateAction {
//        get { self[SettingsNavigateEnvironmentKey.self] }
//        set { self[SettingsNavigateEnvironmentKey.self] = newValue }
//    }
// }
//
// public extension View {
//    func onSettingsNavigate(_ action: @escaping SettingsNavigateAction.Action) -> some View {
//        environment(\.settingsNavigate, SettingsNavigateAction(action: action))
//    }
// }
