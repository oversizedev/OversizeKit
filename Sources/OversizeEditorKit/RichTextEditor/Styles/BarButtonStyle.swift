//
// Copyright © 2024 Alexander Romanov
// BarButtonStyle.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public struct BarButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.xxSmall)
            .background(Circle().fillSurfaceSecondary().opacity(configuration.isPressed ? 1 : 0))
            .padding(.xxxSmall)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public extension ButtonStyle where Self == BarButtonStyle {
    static var bar: BarButtonStyle {
        BarButtonStyle()
    }
}
