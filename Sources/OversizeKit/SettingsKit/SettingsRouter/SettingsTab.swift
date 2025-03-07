//
// Copyright © 2025 Alexander Romanov
// SettingsTab.swift, created on 05.03.2025
//

import OversizeRouter
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
            .init(systemName: "lock")
        case .help:
            .init(systemName: "questionmark.circle")
        case .about:
            .init(systemName: "person.circle")
        case .apperance:
            .init(systemName: "paintbrush")
        case .syncrhonization:
            .init(systemName: "arrow.clockwise")
        }
    }

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
            "syncrhonization"
        }
    }
}
