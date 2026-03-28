//
// Copyright © 2026 Alexander Romanov
// BuiltInBackground.swift
//

import SwiftUI

public enum BuiltInBackground: String, CaseIterable, Identifiable, Sendable {
    case ocean
    case sunset
    case forest
    case night
    case rose
    case lava
    case sky
    case mint
    case peach
    case lavender
    case midnight
    case aurora

    public var id: String {
        rawValue
    }

    public var gradient: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    public var colors: [Color] {
        switch self {
        case .ocean:
            [Color(red: 0.05, green: 0.55, blue: 0.9), Color(red: 0.0, green: 0.3, blue: 0.65)]
        case .sunset:
            [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.85, green: 0.2, blue: 0.45)]
        case .forest:
            [Color(red: 0.2, green: 0.65, blue: 0.35), Color(red: 0.05, green: 0.35, blue: 0.15)]
        case .night:
            [Color(red: 0.1, green: 0.1, blue: 0.25), Color(red: 0.0, green: 0.0, blue: 0.1)]
        case .rose:
            [Color(red: 1.0, green: 0.5, blue: 0.7), Color(red: 0.85, green: 0.2, blue: 0.5)]
        case .lava:
            [Color(red: 1.0, green: 0.35, blue: 0.1), Color(red: 0.7, green: 0.05, blue: 0.05)]
        case .sky:
            [Color(red: 0.55, green: 0.82, blue: 1.0), Color(red: 0.2, green: 0.6, blue: 0.95)]
        case .mint:
            [Color(red: 0.6, green: 0.95, blue: 0.85), Color(red: 0.1, green: 0.7, blue: 0.6)]
        case .peach:
            [Color(red: 1.0, green: 0.8, blue: 0.6), Color(red: 0.95, green: 0.55, blue: 0.35)]
        case .lavender:
            [Color(red: 0.75, green: 0.6, blue: 0.95), Color(red: 0.5, green: 0.3, blue: 0.8)]
        case .midnight:
            [Color(red: 0.15, green: 0.1, blue: 0.4), Color(red: 0.05, green: 0.05, blue: 0.2)]
        case .aurora:
            [Color(red: 0.1, green: 0.85, blue: 0.75), Color(red: 0.3, green: 0.2, blue: 0.8)]
        }
    }
}
