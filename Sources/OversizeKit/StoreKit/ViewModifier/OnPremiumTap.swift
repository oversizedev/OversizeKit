//
// Copyright © 2022 Alexander Romanov
// OnPremiumTap.swift
//

import SwiftUI

public struct OnPremiumTap: ViewModifier {
    @State var isShowPremium = false
    @Environment(\.isPremium) var isPremium
    @Environment(\.colorScheme) var colorScheme
    #if os(macOS)
    @Environment(\.openWindow) var openWindow
    #endif

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
                            isShowPremium.toggle()
                            #endif
                        }
                )
                .sheet(isPresented: $isShowPremium) {
                    StoreView()
                        .systemServices()
                }
        }
    }
}

public extension View {
    func onPremiumTap() -> some View {
        modifier(OnPremiumTap())
    }
}
