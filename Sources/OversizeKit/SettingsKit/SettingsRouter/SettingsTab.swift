//
// Copyright © 2025 Alexander Romanov
// SettingsTab.swift, created on 05.03.2025
//

import OversizeResources
import OversizeRouter
import OversizeUI
import SwiftUI

public enum SettingsTab: Tabable {
    case general
    case apperance
    case syncrhonization
    case security
    case help
    case about
}

public extension SettingsTab {
    var icon: Image {
        switch self {
        case .general:
            .init(systemName: "gearshape")
        case .security:
            .init(systemName: "shield")
        case .help:
            .init(systemName: "questionmark.circle")
        case .about:
            .init(systemName: "person.circle")
        case .apperance:
            .init(systemName: "swatchpalette")
        case .syncrhonization:
            .init(systemName: "icloud")
        }
    }

    /*
     var icon: Image {
         switch self {
         case .general:
             Image.Base.Setting.mini
         case .security:
             Image.Base.lock
         case .help:
             Image.Alert.Help.circle
         case .about:
             Image.Base.Info.circle
         case .apperance:
             Image.Design.paintingPalette
         case .syncrhonization:
             Image.Weather.cloud2
         }
     }
     */

    var title: String {
        switch self {
        case .general:
            .init("General")
        case .security:
            .init("Security")
        case .help:
            .init("Help")
        case .about:
            .init("About")
        case .apperance:
            .init("Appearance")
        case .syncrhonization:
            .init("iCloud")
        }
    }

    var id: String {
        switch self {
        case .general:
            "general"
        case .security:
            "security"
        case .help:
            "help"
        case .about:
            "about"
        case .apperance:
            "apperance"
        case .syncrhonization:
            "icloud"
        }
    }
}
