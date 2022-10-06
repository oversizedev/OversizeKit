//
// Copyright © 2022 Alexander Romanov
// OnPremiumTap.swift
//

import OversizeKit
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
                .sheet(isPresented: $isShowPremium) {
                    StoreView()
                        .systemServices()
                }
                .onTapGesture {
                    isShowPremium.toggle()
                }
        }
    }
}

public extension View {
    func onPremiumTap() -> some View {
        modifier(OnPremiumTap())
    }
}
