//
// Copyright © 2022 Alexander Romanov
// BuyButtonStyle.swift
//

import OversizeUI
import StoreKit
import SwiftUI

struct BuyButtonStyle: ButtonStyle {
    let isPurchased: Bool

    init(isPurchased: Bool = false) {
        self.isPurchased = isPurchased
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        var bgColor: Color = isPurchased ? Color.green : Color.blue
        bgColor = configuration.isPressed ? bgColor.opacity(0.7) : bgColor.opacity(1)

        return configuration.label
            .frame(width: 50)
            .padding(10)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

public struct PaymentButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme: ThemeSettings
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.isLoading) private var isLoading: Bool
    @Environment(\.isAccent) private var isAccent: Bool
    @Environment(\.elevation) private var elevation: Elevation
    @Environment(\.controlSize) var controlSize: ControlSize
    @Environment(\.controlBorderShape) var controlBorderShape: ControlBorderShape
    @Environment(\.isBordered) var isBordered: Bool

    private let isInfinityWidth: Bool?

    public init(infinityWidth: Bool? = nil) {
        isInfinityWidth = infinityWidth
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .body(true)
            .opacity(isLoading ? 0 : 1)
            .foregroundColor(.onPrimaryHighEmphasis)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth)
            .background(background)
            .overlay(loadingView(for: configuration.role))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadowElevaton(elevation)
    }

    @ViewBuilder
    private var background: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                LinearGradient(gradient: Gradient(colors: [Color(hex: "637DFA"), Color(hex: "872BFF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.onSurfaceHighEmphasis.opacity(0.15), lineWidth: 2)
                    .opacity(isBordered || theme.borderButtons ? 1 : 0)
            }
    }

    @ViewBuilder
    private func loadingView(for _: ButtonRole?) -> some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.onPrimaryHighEmphasis))
        } else {
            EmptyView()
        }
    }

    private var horizontalPadding: Space {
        switch controlSize {
        case .mini:
            return .xxSmall
        case .small:
            return .small
        case .regular:
            return .small
        case .large, .extraLarge:
            return .medium
        @unknown default:
            return .zero
        }
    }

    private var verticalPadding: Space {
        switch controlSize {
        case .mini:
            return .xxSmall
        case .small:
            return .xxSmall
        case .regular:
            return .small
        case .large, .extraLarge:
            return .medium
        @unknown default:
            return .zero
        }
    }

    private var backgroundOpacity: CGFloat {
        isEnabled ? 1 : 0.5
    }

    private var foregroundOpacity: CGFloat {
        isEnabled ? 1 : 0.7
    }

    private var maxWidth: CGFloat? {
        if isInfinityWidth == nil, controlSize == .regular {
            return .infinity
        } else if let infinity = isInfinityWidth, infinity == true {
            return .infinity
        } else {
            return nil
        }
    }
}

public extension ButtonStyle where Self == PaymentButtonStyle {
    static var payment: PaymentButtonStyle {
        PaymentButtonStyle()
    }
}
