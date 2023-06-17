//
// Copyright © 2022 Alexander Romanov
// OnPremiumTap.swift
//

import SwiftUI

public struct OnPremiumTap: ViewModifier {
    @State var isShowPremium = false
    @Environment(\.isPremium) var isPremium
    @Environment(\.colorScheme) var colorScheme
    public func body(content: Content) -> some View {
        if isPremium {
            content
        } else {
            content
                .disabled(true)
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            isShowPremium.toggle()
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
