//
// Copyright © 2026 Alexander Romanov
// GradientDirection.swift
//

import SwiftUI

public enum GradientDirection: String, CaseIterable, Identifiable, Sendable {
    case topBottom
    case bottomTop
    case leadingTrailing
    case trailingLeading
    case topLeadingBottomTrailing
    case topTrailingBottomLeading

    public var id: String {
        rawValue
    }

    public var startPoint: UnitPoint {
        switch self {
        case .topBottom: .top
        case .bottomTop: .bottom
        case .leadingTrailing: .leading
        case .trailingLeading: .trailing
        case .topLeadingBottomTrailing: .topLeading
        case .topTrailingBottomLeading: .topTrailing
        }
    }

    public var endPoint: UnitPoint {
        switch self {
        case .topBottom: .bottom
        case .bottomTop: .top
        case .leadingTrailing: .trailing
        case .trailingLeading: .leading
        case .topLeadingBottomTrailing: .bottomTrailing
        case .topTrailingBottomLeading: .bottomLeading
        }
    }

    public var systemImage: String {
        switch self {
        case .topBottom: "arrow.down"
        case .bottomTop: "arrow.up"
        case .leadingTrailing: "arrow.right"
        case .trailingLeading: "arrow.left"
        case .topLeadingBottomTrailing: "arrow.down.right"
        case .topTrailingBottomLeading: "arrow.down.left"
        }
    }

    public var title: String {
        switch self {
        case .topBottom: "Top to Bottom"
        case .bottomTop: "Bottom to Top"
        case .leadingTrailing: "Left to Right"
        case .trailingLeading: "Right to Left"
        case .topLeadingBottomTrailing: "Diagonal"
        case .topTrailingBottomLeading: "Diagonal"
        }
    }
}
