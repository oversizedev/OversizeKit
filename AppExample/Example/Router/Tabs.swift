//
// Copyright © 2023 Alexander Romanov
// Tabs.swift, created on 25.09.2023
//

import SwiftUI

public enum RootTab: String {
    case main
    case secondary
    case tertiary
    case quaternary
    case settings

    var id: String {
        switch self {
        case .main:
            "home"
        case .secondary:
            "secondary"
        case .tertiary:
            "tertiary"
        case .quaternary:
            "quaternary"
        case .settings:
            "settings"
        }
    }

    var title: String {
        switch self {
        case .main:
            "Home"
        case .secondary:
            "Secondary"
        case .tertiary:
            "Tertiary"
        case .quaternary:
            "Quaternary"
        case .settings:
            "Settings"
        }
    }

    var image: Image {
        switch self {
        case .main:
            Image(systemName: "")
        case .secondary:
            Image(systemName: "")
        case .tertiary:
            Image(systemName: "")
        case .quaternary:
            Image(systemName: "")
        case .settings:
            Image(systemName: "")
        }
    }
}
