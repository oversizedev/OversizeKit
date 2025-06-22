//
// Copyright © 2024 Alexander Romanov
// SettingsScreen.swift, created on 15.04.2024
//

import Foundation
import OversizeModels
import OversizeNetwork

public enum SettingsDestinations: Hashable {
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
    case debugMenu
    case debugInfo
}
