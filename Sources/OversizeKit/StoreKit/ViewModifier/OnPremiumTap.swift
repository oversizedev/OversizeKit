//
// Copyright © 2022 Alexander Romanov
// OnPremiumTap.swift
//

import NavigatorUI
import SwiftUI

public struct OnPremiumTap: ViewModifier {
    @Environment(\.isPremium) var isPremium
    @Environment(\.colorScheme) var colorScheme
    #if os(macOS)
    @Environment(\.openWindow) var openWindow
    #endif
    @Environment(\.navigator) var navigator

    public func body(content: Content) -> some View {
        if isPremium {
            content
        } else {
            content
                .disabled(true)
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            #if os(macOS)
                            openWindow(id: "Window.StoreView")
                            #else
                            navigator.navigate(to: SettingsDestinations.premium)
                            #endif
                        }
                )
        }
    }
}

public extension View {
    func onPremiumTap() -> some View {
        modifier(OnPremiumTap())
    }
}
