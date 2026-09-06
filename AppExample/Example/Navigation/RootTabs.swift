//
// Copyright © 2023 Alexander Romanov
// RootTabs.swift, created on 25.09.2023
//

import Foundation

enum RootTab: String, CaseIterable, Identifiable {
    case main
    case demo
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .main:
            "Home"
        case .demo:
            "Kits"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .main:
            "house"
        case .demo:
            "square.grid.2x2"
        case .settings:
            "gearshape"
        }
    }
}
