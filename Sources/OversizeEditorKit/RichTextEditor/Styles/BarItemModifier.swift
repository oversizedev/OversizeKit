//
// Copyright © 2024 Alexander Romanov
// BarItemModifier.swift, created on 20.05.2026
//

import OversizeUI
import SwiftUI

extension EnvironmentValues {
    @Entry var barScrollInteracting: Bool = false
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct BarItemScrollHapticModifier: ViewModifier {
    @Environment(\.barScrollInteracting) private var isScrollInteracting
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .onScrollVisibilityChange(threshold: 0.5) { visible in
                isVisible = visible
            }
            .sensoryFeedback(.selection, trigger: isVisible) { _, newValue in
                !newValue && isScrollInteracting
            }
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
extension View {
    func barItem(namespace: Namespace.ID) -> some View {
        glassEffectUnion(id: "bar", namespace: namespace)
        #if os(iOS)
            .glassEffectTransition(.identity)
        #endif
            .scrollTransition(.interactive) { content, phase in
                let t = max(0, phase.value)
                return content
                    .opacity(1.0 - min(1.0, t * 2.5))
                    .scaleEffect(1.0 - min(0.25, t * 0.6))
                    .blur(radius: max(0, t - 0.8) * 8)
                    .offset(x: -t * 10)
            }
            .modifier(BarItemScrollHapticModifier())
    }
}
